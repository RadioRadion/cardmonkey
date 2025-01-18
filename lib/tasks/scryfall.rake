require 'net/http'
require 'json'
require 'fileutils'

namespace :scryfall do
  desc "Download latest Scryfall data and update cards/prices"
  task sync: :environment do
    puts "Starting Scryfall sync..."
    
    # Créer les dossiers nécessaires
    data_dir = Rails.root.join('tmp', 'scryfall')
    FileUtils.mkdir_p(data_dir)
    
    # Télécharger les données
    puts "Downloading Scryfall data..."
    bulk_data_url = 'https://api.scryfall.com/bulk-data'
    bulk_data = JSON.parse(Net::HTTP.get(URI(bulk_data_url)))
    default_cards = bulk_data['data'].find { |item| item['type'] == 'default_cards' }
    
    if default_cards
      cards_data = Net::HTTP.get(URI(default_cards['download_uri']))
      File.write(data_dir.join('all-cards.json'), cards_data)
      puts "Download completed!"
      
      # Mettre à jour la base de données
      puts "Updating database..."
      cards = JSON.parse(cards_data)
      
      # Créer un hash pour stocker les cartes par oracle_id
      cards_by_oracle_id = {}
      
      # Premier passage : regrouper les cartes par oracle_id
      puts "Organizing cards..."
      cards.each do |card_data|
        next unless ['en', 'fr'].include?(card_data['lang'])
        oracle_id = card_data['oracle_id']
        
        cards_by_oracle_id[oracle_id] ||= {
          en: nil,
          fr: nil,
          versions: []
        }
        
        if card_data['lang'] == 'en'
          cards_by_oracle_id[oracle_id][:en] = card_data
        elsif card_data['lang'] == 'fr'
          cards_by_oracle_id[oracle_id][:fr] = card_data
        end
        
        # Stocker les données de version uniques
        unless cards_by_oracle_id[oracle_id][:versions].any? { |v| v['id'] == card_data['id'] }
          cards_by_oracle_id[oracle_id][:versions] << card_data
        end
      end
      
      # Deuxième passage : créer/mettre à jour les cartes et leurs versions
      puts "Processing cards in batches..."
      cards_by_oracle_id.each_slice(100) do |batch|
        ActiveRecord::Base.transaction do
          batch.each do |oracle_id, data|
            next unless data[:en] && data[:fr] # Skip si on n'a pas les deux langues
            
            # Créer ou mettre à jour la carte
            card = Card.find_or_initialize_by(scryfall_oracle_id: oracle_id)
            card.name_en = data[:en]['name']
            card.name_fr = data[:fr]['printed_name'] || data[:fr]['name']
            
            if card.save
              # Traiter chaque version unique de la carte
              data[:versions].each do |version_data|
                # Trouver ou créer l'extension
                extension = Extension.find_or_create_by!(
                  code: version_data['set'],
                  name: version_data['set_name']
                )
                
                # Créer ou mettre à jour la version
                card_version = CardVersion.find_or_initialize_by(
                  card_id: card.id,
                  scryfall_id: version_data['id']
                )
                
                card_version.assign_attributes(
                  img_uri: version_data.dig('image_uris', 'normal'),
                  eur_price: version_data.dig('prices', 'eur'),
                  eur_foil_price: version_data.dig('prices', 'eur_foil'),
                  rarity: version_data['rarity'],
                  frame: version_data['frame'],
                  border_color: version_data['border_color'],
                  extension_id: extension.id,
                  collector_number: version_data['collector_number']
                )
                
                card_version.save!
              end
            end
          end
        end
      end
      
      puts "Sync completed successfully!"
    else
      puts "Error: Could not find default cards data"
    end
  end
end
