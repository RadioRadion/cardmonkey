class Want < ApplicationRecord
  belongs_to :user
  belongs_to :image
  has_many :matches, dependent: :destroy
  has_many :cards, through: :matches

  after_save :find_want_matches

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

  def find_want_matches
    Card.where(name: self.name).where.not(user_id: self.user_id).find_each do |card|
      Match.create!(card_id: card.id, want_id: self.id)
    end
  end
end
