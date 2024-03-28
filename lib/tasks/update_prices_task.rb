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
      scryfall_id = card_data['id']
      price_eur = card_data['prices']['eur']

      # Nous utilisons scryfall_id pour identifier de manière unique chaque CardVersion
      if card_version = CardVersion.find_by(scryfall_id: scryfall_id)
        card_version.update(price: price_eur)
        updated_cards.add(scryfall_id)
      end
    end

    puts "#{updated_cards.size} card versions prices updated."
  end
end
