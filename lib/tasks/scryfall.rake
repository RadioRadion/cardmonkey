require 'net/http'
require 'json'

namespace :scryfall do
  task sync: :environment do
    puts "Starting Scryfall sync..."
    
    def fetch_json(url)
      uri = URI(url)
      response = Net::HTTP.get_response(uri)
      JSON.parse(response.body)
    rescue => e
      puts "Error fetching #{url}: #{e.message}"
      sleep(5)
      retry
    end

    def process_card_version(card, version_data)
      extension = Extension.find_or_create_by!(
        code: version_data['set'],
        name: version_data['set_name']
      )

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

    cards_processed = 0
    
    # Traitement des cartes en anglais
    page = 1
    puts "Processing English cards..."
    
    loop do
      puts "Fetching English page #{page}..."
      url = "https://api.scryfall.com/cards/search?q=lang%3Aen&page=#{page}&unique=prints"
      data = fetch_json(url)
      
      data['data'].each do |card_data|
        begin
          Card.transaction do
            card = Card.find_or_initialize_by(scryfall_oracle_id: card_data['oracle_id'])
            card.name_en = card_data['name']
            card.name_fr ||= card_data['name'] # Valeur par défaut en attendant la version FR
            card.save!

            process_card_version(card, card_data)
          end
          cards_processed += 1
          puts "Processed English card: #{card_data['name']}" if (cards_processed % 100).zero?
        rescue => e
          puts "Error processing English card #{card_data['name']}: #{e.message}"
          next
        end
      end

      break unless data['has_more']
      page += 1
      sleep(0.1)
    end

    # Traitement des cartes en français
    page = 1
    puts "\nProcessing French cards..."
    
    loop do
      puts "Fetching French page #{page}..."
      url = "https://api.scryfall.com/cards/search?q=lang%3Afr&page=#{page}&unique=prints"
      data = fetch_json(url)
      
      data['data'].each do |card_data|
        begin
          if card = Card.find_by(scryfall_oracle_id: card_data['oracle_id'])
            Card.transaction do
              card.update!(name_fr: card_data['printed_name'])
              process_card_version(card, card_data)
            end
            puts "Updated French version for: #{card.name_en}" if (cards_processed % 100).zero?
          end
        rescue => e
          puts "Error processing French card #{card_data['printed_name']}: #{e.message}"
          next
        end
      end

      break unless data['has_more']
      page += 1
      sleep(0.1)
    end

    puts "\nSync completed! Processed #{cards_processed} cards"
  end
end