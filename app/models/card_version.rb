class CardVersion < ApplicationRecord
  belongs_to :card
  has_many :user_cards
  belongs_to :extension

end
