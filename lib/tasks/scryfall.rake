require 'net/http'
require 'json'

namespace :scryfall do
  desc "Sync cards from Scryfall. Use LIMIT=100 to sync only a limited number of successful cards. Use MAX_ATTEMPTS=500 to limit total attempts."
  task sync: :environment do
    limit = ENV['LIMIT'] ? ENV['LIMIT'].to_i : nil
    max_attempts = ENV['MAX_ATTEMPTS'] ? ENV['MAX_ATTEMPTS'].to_i : (limit ? limit * 5 : nil) # Default to 5x limit if limit is set
    
    puts "Starting Scryfall sync#{limit ? " (limited to #{limit} successful cards)" : ''}..."
    puts "Maximum attempts set to: #{max_attempts}" if max_attempts
    
    def fetch_json(url)
      uri = URI(url)
      response = Net::HTTP.get_response(uri)
      JSON.parse(response.body)
    rescue => e
      puts "Error fetching #{url}: #{e.message}"
      sleep(5)
      retry
    end

    def fetch_set_data(set_code, set_cache)
      set_cache[set_code] ||= begin
        url = "https://api.scryfall.com/sets/#{set_code}"
        fetch_json(url)
      end
    end

    def process_card_version(card, version_data, stats, set_cache)
      set_data = fetch_set_data(version_data['set'], set_cache)
      
      extension = Extension.find_or_create_by!(
        code: version_data['set'],
        name: version_data['set_name'],
        release_date: set_data['released_at'],
        icon_uri: set_data['icon_svg_uri']
      )

      card_version = CardVersion.find_or_initialize_by(
        card_id: card.id,
        scryfall_id: version_data['id']
      )
      
      is_new_version = card_version.new_record?

      # Get the image URIs from the card data
      img_uri = version_data.dig('image_uris', 'normal')
      icon_uri = version_data.dig('image_uris', 'small')

      # For double-faced cards
      if !img_uri && !icon_uri
        img_uri = version_data.dig('card_faces', 0, 'image_uris', 'normal')
        icon_uri = version_data.dig('card_faces', 0, 'image_uris', 'small')
      end

      # Convertir les prix en decimal ou nil
      eur_price = version_data.dig('prices', 'eur')
      eur_price = eur_price.to_d if eur_price.present?
      
      eur_foil_price = version_data.dig('prices', 'eur_foil')
      eur_foil_price = eur_foil_price.to_d if eur_foil_price.present?
      
      # Log des prix pour debug
      puts "Prices for #{version_data['name']} (#{version_data['set']}): EUR: #{eur_price}, EUR Foil: #{eur_foil_price}"
      
      card_version.assign_attributes(
        img_uri: img_uri,
        eur_price: eur_price,
        eur_foil_price: eur_foil_price,
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
      
      true # Indicate success
    rescue => e
      puts "Error processing version for card #{card.name_en}: #{e.message}"
      false # Indicate failure
    end

    stats = {
      cards_created: 0,
      cards_updated: 0,
      versions_created: 0,
      versions_updated: 0,
      total_attempts: 0,
      successful_operations: 0
    }
    
    set_cache = {}
    batch_size = 20 # Traiter 20 cartes à la fois
    
    # Traitement des cartes en anglais
    page = 1
    puts "Processing English cards..."
    
    loop do
      # Check if we've hit either limit
      if limit && stats[:successful_operations] >= limit
        puts "\nReached limit of #{limit} successful operations. Stopping sync..."
        break
      end
      
      if max_attempts && stats[:total_attempts] >= max_attempts
        puts "\nReached maximum attempts limit of #{max_attempts}. Stopping sync..."
        break
      end

      puts "Fetching English page #{page}..."
      url = "https://api.scryfall.com/cards/search?q=lang%3Aen&page=#{page}&unique=prints"
      data = fetch_json(url)
      
      # Grouper les cartes par oracle_id pour éviter les doublons
      cards_by_oracle_id = data['data'].group_by { |card| card['oracle_id'] }
      
      cards_by_oracle_id.each do |oracle_id, versions|
        stats[:total_attempts] += 1
        
        begin
          # Utiliser la première version anglaise comme référence
          first_version = versions.first
          
          success = false
          Card.transaction do
            # Vérifier que l'oracle_id est présent
            if oracle_id.blank?
              puts "Skipping card with blank oracle_id: #{first_version['name']}"
              next
            end
            
            # Trouver ou créer la carte unique
            card = Card.find_or_initialize_by(scryfall_oracle_id: oracle_id)
            is_new_card = card.new_record?
            
            card.assign_attributes(
              name_en: first_version['name'],
              name_fr: first_version['name'] # Valeur par défaut en attendant la version FR
            )
            card.save!

            # Traiter toutes les versions pour cette carte
            versions.each do |version_data|
              if process_card_version(card, version_data, stats, set_cache)
                success = true
                stats[:successful_operations] += 1
              end
            end

            if is_new_card
              stats[:cards_created] += 1
              puts "Created new card: #{card.name_en}"
            else
              stats[:cards_updated] += 1
              puts "Updated existing card: #{card.name_en}" if (stats[:cards_updated] % 100).zero?
            end
          end
        rescue => e
          puts "Error processing English card #{first_version['name']}: #{e.message}"
        end

        if max_attempts && stats[:total_attempts] >= max_attempts
          puts "\nReached maximum attempts limit of #{max_attempts}. Stopping sync..."
          break
        end
        
        if limit && stats[:successful_operations] >= limit
          puts "\nReached limit of #{limit} successful operations. Stopping sync..."
          break
        end
      end

      break if !data['has_more'] || 
               (limit && stats[:successful_operations] >= limit) ||
               (max_attempts && stats[:total_attempts] >= max_attempts)
               
      # Pause plus longue entre les pages pour permettre au GC de faire son travail
      page += 1
      GC.start # Force garbage collection
      sleep(1)
    end

    # Only process French cards if we haven't hit our limits
    if (!limit || stats[:successful_operations] < limit) &&
       (!max_attempts || stats[:total_attempts] < max_attempts)
      
      page = 1
      puts "\nProcessing French cards..."
      
      loop do
        if limit && stats[:successful_operations] >= limit
          puts "\nReached limit of #{limit} successful operations. Stopping sync..."
          break
        end
        
        if max_attempts && stats[:total_attempts] >= max_attempts
          puts "\nReached maximum attempts limit of #{max_attempts}. Stopping sync..."
          break
        end

        puts "Fetching French page #{page}..."
        url = "https://api.scryfall.com/cards/search?q=lang%3Afr&page=#{page}&unique=prints"
        data = fetch_json(url)
        
        data['data'].each do |card_data|
          stats[:total_attempts] += 1
          
          begin
            success = false
            if card = Card.find_by(scryfall_oracle_id: card_data['oracle_id'])
              Card.transaction do
                card.update!(name_fr: card_data['printed_name'])
                
                if process_card_version(card, card_data, stats, set_cache)
                  stats[:cards_updated] += 1
                  puts "Updated French version for: #{card.name_en}" if (stats[:cards_updated] % 100).zero?
                  success = true
                  stats[:successful_operations] += 1
                end
              end
            end
          rescue => e
            puts "Error processing French card #{card_data['printed_name']}: #{e.message}"
          end

          if max_attempts && stats[:total_attempts] >= max_attempts
            puts "\nReached maximum attempts limit of #{max_attempts}. Stopping sync..."
            break
          end
          
          if limit && stats[:successful_operations] >= limit
            puts "\nReached limit of #{limit} successful operations. Stopping sync..."
            break
          end
        end

        break if !data['has_more'] || 
                 (limit && stats[:successful_operations] >= limit) ||
                 (max_attempts && stats[:total_attempts] >= max_attempts)
        # Pause plus longue entre les pages pour permettre au GC de faire son travail
        page += 1
        GC.start # Force garbage collection
        sleep(1)
      end
    end

    puts "\nSync completed!"
    puts "Cards created: #{stats[:cards_created]}"
    puts "Cards updated: #{stats[:cards_updated]}"
    puts "Card versions created: #{stats[:versions_created]}"
    puts "Card versions updated: #{stats[:versions_updated]}"
    puts "Total attempts: #{stats[:total_attempts]}"
    puts "Successful operations: #{stats[:successful_operations]}"
  end
end
