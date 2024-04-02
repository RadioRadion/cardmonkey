class UserWantedCard < ApplicationRecord
  belongs_to :user
  belongs_to :card
  has_many :matches
  validates :scryfall_oracle_id, presence: true

  enum min_condition: { poor: "0", played: "1", light_played: "2", good: "3",
    excellent: "4", near_mint: "5", mint: "6", unimportant: "7" }
  enum language: { français: "0", anglais: "1", allemand: "2", italien: "3", chinois_s: "4",
    chinois_t: "5", japonais: "6", portuguais: "7", russe: "8", corréen: "9", dont_care: "10" }

  def price
    card.price
  end

  def name_en
    card.name_en
  end

  def name_fr
    card.name_fr
  end
end
