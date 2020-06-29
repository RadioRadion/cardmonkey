class CardTrade < ApplicationRecord
  belongs_to :trade
  belongs_to :card
end
