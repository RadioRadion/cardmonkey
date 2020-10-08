class Trade < ApplicationRecord
  belongs_to :user
  has_many :card_trades
  has_many :cards, through: :card_trades
end
