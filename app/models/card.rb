class Card < ApplicationRecord
  belongs_to :user
  belongs_to :image
  has_many :card_trades
  has_many :trades, through: :card_trades
  has_many :matches, dependent: :destroy
  has_many :wants, through: :matches

  validates :name, presence: true
  validates :quantity, presence: true
  validates :extension, presence: true
  validates :foil, presence: true

  def self.getprices
    Card.all.each do |card|
      image = Image.find(card.image_id)
      url = 'https://api.scryfall.com/cards/' + image.api_id
      card_serialized = open(url).read
      card = JSON.parse(card_serialized)
      price = card["prices"]["eur"]
      image.update(price: price)
    end
  end

end
