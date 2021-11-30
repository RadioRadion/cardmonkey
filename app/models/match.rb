class Match < ApplicationRecord
  belongs_to :user
  belongs_to :user_card
  belongs_to :user_wanted_card

  validates :user_id_target, presence: true
end
