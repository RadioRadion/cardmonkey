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
      
      # Traiter les cartes par lots
      cards.each_slice(1000) do |batch|
        ActiveRecord::Base.transaction do
          batch.each do |card_data|
            next unless ['en', 'fr'].include?(card_data['lang'])
            
            # Créer ou mettre à jour la carte
            card = Card.find_or_initialize_by(scryfall_oracle_id: card_data['oracle_id'])
            card.name_en = card_data['name'] if card_data['lang'] == 'en'
            card.name_fr = card_data['printed_name'] if card_data['lang'] == 'fr'
            card.save!
            
            # Créer ou mettre à jour la version
            card_version = CardVersion.find_or_initialize_by(
              card_id: card.id,
              scryfall_id: card_data['id']
            )
            
            card_version.update!(
              img_uri: card_data.dig('image_uris', 'normal'),
              eur_price: card_data.dig('prices', 'eur'),
              eur_foil_price: card_data.dig('prices', 'eur_foil')
            )
          end
        end
      end
      
      puts "Sync completed successfully!"
    else
      puts "Error: Could not find default cards data"
    end
  end
end
