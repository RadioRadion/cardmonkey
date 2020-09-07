class Trade < ApplicationRecord
  belongs_to :user
  has_many :cards, through: :card_trades
end
