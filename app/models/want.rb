class Want < ApplicationRecord
  belongs_to :user
  belongs_to :image

  def self.getprices
    Want.all.each do |want|
      image = Image.find(want.image_id)
      url = 'https://api.scryfall.com/cards/' + image.api_id
      card_serialized = open(url).read
      card = JSON.parse(card_serialized)
      price = card["prices"]["eur"]
      image.update(price: price)
    end
  end
end
