# lib/tasks/add_new_cards.rb
require 'json'

module InitializeCardsTask
  def self.perform
    json_file_path = Rails.root.join('tmp', 'scryfall', 'all-cards.json')

    file = File.read(json_file_path)
    cards_data = JSON.parse(file)

    cards_data.each do |card_data|
      next unless ['en', 'fr'].include?(card_data['lang'])

      scryfall_oracle_id = card_data['oracle_id']

      card = Card.find_or_initialize_by(scryfall_oracle_id: scryfall_oracle_id)
      
      if card_data['lang'] == 'en'
        card.name_en ||= card_data['name']
      elsif card_data['lang'] == 'fr'
        card.name_fr ||= card_data['printed_name'] || card_data['name']
      end
      
      card.save if card.changed?

      CardVersion.find_or_create_by(card: card, scryfall_id: card_data['id']) do |cv|
        cv.extension = card_data['set']
        cv.img_uri = card_data.dig('image_uris', 'normal')
        cv.eur_price = card_data.dig('prices', 'eur')
      end
    end

    puts "Cards and card versions have been updated."
  end
end
