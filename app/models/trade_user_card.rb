class TradeUserCard < ApplicationRecord
  belongs_to :trade
  belongs_to :user_card
end
