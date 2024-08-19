class CardVersion < ApplicationRecord
  belongs_to :card
  has_many :user_cards
  belongs_to :extension

  validates :card_id, presence: true
  validates :scryfall_id, presence: true
  validates :rarity, presence: true
  validates :frame, presence: true
  validates :border_color, presence: true
  validates :extension_id, presence: true

end
