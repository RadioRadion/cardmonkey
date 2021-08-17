class UserWantedCard < ApplicationRecord
  belongs_to :user
  belongs_to :card
end
