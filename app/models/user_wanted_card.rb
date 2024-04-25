class UserWantedCard < ApplicationRecord
  belongs_to :user
  belongs_to :card
  belongs_to :card_version, optional: true
  has_many :matches

  validates :quantity, presence: true
  validates :min_condition, presence: true
  validates :language, presence: true
  validates :foil, inclusion: { in: [true, false], message: "can't be blank" }

  enum min_condition: { poor: "0", played: "1", light_played: "2", good: "3",
    excellent: "4", near_mint: "5", mint: "6", unimportant: "7" }
  enum language: { français: "0", anglais: "1", allemand: "2", italien: "3", chinois_s: "4",
    chinois_t: "5", japonais: "6", portuguais: "7", russe: "8", corréen: "9", dont_care: "10" }

  def name_en
    card.name_en
  end

  def name_fr
    card.name_fr
  end

  def img_want_uri
    self.card_version_id.nil? ? self.card.card_versions.first.img_uri : self.card_version.img_uri
  end
  
end