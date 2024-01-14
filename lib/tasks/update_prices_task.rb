# lib/tasks/update_prices_task.rb
require 'json'
require 'set'

module UpdatePricesTask
  def self.perform
    json_file_path = Rails.root.join('tmp', 'scryfall', 'all-cards.json')

    file = File.read(json_file_path)
    cards_data = JSON.parse(file)

    updated_cards = Set.new

    cards_data.each do |card_data|
      scryfall_oracle_id = card_data['oracle_id']

      next if updated_cards.include?(scryfall_oracle_id)

      price_eur = card_data['prices']['eur']

      if card = Card.find_by(scryfall_oracle_id: scryfall_oracle_id)
        card.update(price: price_eur)
        updated_cards.add(scryfall_oracle_id)
      end
    end
  end
end
