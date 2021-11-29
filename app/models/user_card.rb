class UserCard < ApplicationRecord
  belongs_to :user
  belongs_to :card

  accepts_nested_attributes_for :card

  enum condition: { mint: "0", near_mint: "1", excellent: "2", good: "3",
    light_played: "4", played: "5", poor: "6" }
  enum language: { français: "0", anglais: "1", allemand: "2", italien: "3", chinois_s: "4",
    chinois_t: "5", japonais: "6", portuguais: "7", russe: "8", corréen: "9" }

  def price
    card.price
  end
end
