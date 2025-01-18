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

    page = 1
    cards_processed = 0
    
    loop do
      puts "Processing page #{page}..."
      url = "https://api.scryfall.com/cards/search?q=lang%3Aen+or+lang%3Afr&page=#{page}&unique=prints"
      data = fetch_json(url)
      
      data['data'].each do |card_data|
        Card.transaction do
          card = Card.find_or_initialize_by(scryfall_oracle_id: card_data['oracle_id'])
          card.name_en = card_data['name'] if card_data['lang'] == 'en'
          card.name_fr = card_data['printed_name'] if card_data['lang'] == 'fr'
          card.save!

          CardVersion.find_or_initialize_by(
            card_id: card.id,
            scryfall_id: card_data['id']
          ).update!(
            img_uri: card_data.dig('image_uris', 'normal'),
            eur_price: card_data.dig('prices', 'eur'),
            eur_foil_price: card_data.dig('prices', 'eur_foil')
          )
        end
        cards_processed += 1
      end

      puts "Processed #{cards_processed} cards"
      
      break unless data['has_more']
      page += 1
      sleep(0.1) # Respect du rate limiting
    end

    puts "Sync completed!"
  end
end