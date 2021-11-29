class UserWantedCard < ApplicationRecord
  belongs_to :user
  belongs_to :card

  enum min_condition: { mint: "0", near_mint: "1", excellent: "2", good: "3",
    light_played: "4", played: "5", poor: "6", unimportant: "7" }
  enum language: { français: "0", anglais: "1", allemand: "2", italien: "3", chinois_s: "4",
    chinois_t: "5", japonais: "6", portuguais: "7", russe: "8", corréen: "9", dont_care: "10" }
end
