require 'net/http'
require 'json'
require 'fileutils'

namespace :scryfall do
  desc "Download latest Scryfall data and update cards/prices"
  task sync: :environment do
    puts "Starting Scryfall sync..."
    
    # Télécharger les données en streaming
    puts "Downloading Scryfall data..."
    bulk_data_url = 'https://api.scryfall.com/bulk-data'
    bulk_data = JSON.parse(Net::HTTP.get(URI(bulk_data_url)))
    default_cards = bulk_data['data'].find { |item| item['type'] == 'default_cards' }
    
    if default_cards
      uri = URI(default_cards['download_uri'])
      batch_size = 100
      buffer = ""
      cards_processed = 0
      
      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        request = Net::HTTP::Get.new(uri)
        
        http.request(request) do |response|
          response.read_body do |chunk|
            buffer += chunk
            
            # Traiter le buffer dès qu'on trouve des objets JSON complets
            while (match = buffer.match(/\{[^}]+\},?/))
              card_json = match[0].chomp(',')
              buffer = buffer[match.end(0)..-1]
              
              begin
                card_data = JSON.parse(card_json)
                next unless ['en', 'fr'].include?(card_data['lang'])
                
                ActiveRecord::Base.transaction do
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
                
                cards_processed += 1
                puts "Processed #{cards_processed} cards" if (cards_processed % 1000).zero?
              rescue JSON::ParserError => e
                puts "Error parsing card JSON: #{e.message}"
                next
              end
            end
          end
        end
      end
      
      puts "Sync completed successfully! Processed #{cards_processed} cards"
    else
      puts "Error: Could not find default cards data"
    end
  end
end