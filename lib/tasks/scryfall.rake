require 'net/http'
require 'json'

namespace :scryfall do
  desc "Sync cards from Scryfall. Use LIMIT=100 to sync only a limited number of cards. Safe to run multiple times - will update existing cards."
  task sync: :environment do
    limit = ENV['LIMIT'] ? ENV['LIMIT'].to_i : nil
    puts "Starting Scryfall sync#{limit ? " (limited to #{limit} cards)" : ''}..."
    
    def fetch_json(url)
      uri = URI(url)
      response = Net::HTTP.get_response(uri)
      JSON.parse(response.body)
    rescue => e
      puts "Error fetching #{url}: #{e.message}"
      sleep(5)
      retry
    end

    def process_card_version(card, version_data, stats)
      extension = Extension.find_or_create_by!(
        code: version_data['set'],
        name: version_data['set_name']
      )

      card_version = CardVersion.find_or_initialize_by(
        card_id: card.id,
        scryfall_id: version_data['id']
      )
      
      is_new_version = card_version.new_record?

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

      if is_new_version
        stats[:versions_created] += 1
      else
        stats[:versions_updated] += 1
      end
    end

    stats = {
      cards_created: 0,
      cards_updated: 0,
      versions_created: 0,
      versions_updated: 0,
      total_processed: 0
    }
    
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
            is_new_card = card.new_record?
            
            card.name_en = card_data['name']
            card.name_fr ||= card_data['name'] # Valeur par défaut en attendant la version FR
            card.save!

            if is_new_card
              stats[:cards_created] += 1
              puts "Created new card: #{card.name_en}"
            else
              stats[:cards_updated] += 1
              puts "Updated existing card: #{card.name_en}" if (stats[:cards_updated] % 100).zero?
            end

            process_card_version(card, card_data, stats)
          end
          
          stats[:total_processed] += 1
          
          if limit && stats[:total_processed] >= limit
            puts "\nReached limit of #{limit} cards. Stopping sync..."
            puts "\nSync stats:"
            puts "Cards created: #{stats[:cards_created]}"
            puts "Cards updated: #{stats[:cards_updated]}"
            puts "Card versions created: #{stats[:versions_created]}"
            puts "Card versions updated: #{stats[:versions_updated]}"
            puts "Total processed: #{stats[:total_processed]}"
            return
          end
        rescue => e
          puts "Error processing English card #{card_data['name']}: #{e.message}"
          next
        end
      end

      break if !data['has_more'] || (limit && stats[:total_processed] >= limit)
      page += 1
      sleep(0.1)
    end

    # Traitement des cartes en français
    page = 1
    puts "\nProcessing French cards..."
    
    loop do
      break if limit && stats[:total_processed] >= limit

      puts "Fetching French page #{page}..."
      url = "https://api.scryfall.com/cards/search?q=lang%3Afr&page=#{page}&unique=prints"
      data = fetch_json(url)
      
      data['data'].each do |card_data|
        begin
          if card = Card.find_by(scryfall_oracle_id: card_data['oracle_id'])
            Card.transaction do
              card.update!(name_fr: card_data['printed_name'])
              process_card_version(card, card_data, stats)
              stats[:cards_updated] += 1
            end
            puts "Updated French version for: #{card.name_en}" if (stats[:cards_updated] % 100).zero?
            
            stats[:total_processed] += 1
            
            if limit && stats[:total_processed] >= limit
              puts "\nReached limit of #{limit} cards. Stopping sync..."
              break
            end
          end
        rescue => e
          puts "Error processing French card #{card_data['printed_name']}: #{e.message}"
          next
        end
      end

      break if !data['has_more'] || (limit && stats[:total_processed] >= limit)
      page += 1
      sleep(0.1)
    end

    puts "\nSync completed!"
    puts "Cards created: #{stats[:cards_created]}"
    puts "Cards updated: #{stats[:cards_updated]}"
    puts "Card versions created: #{stats[:versions_created]}"
    puts "Card versions updated: #{stats[:versions_updated]}"
    puts "Total processed: #{stats[:total_processed]}"
  end
end
