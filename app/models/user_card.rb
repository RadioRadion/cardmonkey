class UserCard < ApplicationRecord
  belongs_to :user
  belongs_to :card
  has_many :matches

  # accepts_nested_attributes_for :card

  enum condition: { mint: "0", near_mint: "1", excellent: "2", good: "3",
    light_played: "4", played: "5", poor: "6" }
  enum language: { français: "0", anglais: "1", allemand: "2", italien: "3", chinois_s: "4",
    chinois_t: "5", japonais: "6", portuguais: "7", russe: "8", corréen: "9" }

  after_save :check_matches

  def price
    card.price
  end

  def name
    card.name
  end

  def check_matches(users_to_check = [])
    matches.destroy_all
    if users_to_check.blank?
      user_wanted_cards = UserWantedCard.where.not(user_id: user.id)
    else
      users_around = User.near(user.address, user.area).map(&:id).delete(user.id)
      user_wanted_cards = UserWantedCard.where(user_id: users_around)
    end
    user_wanted_cards.each do |user_wanted_card|
      Match.create!(
        user_card_id: id,
        user_wanted_card_id: user_wanted_card.id,
        user_id: user.id,
        user_id_target: user_wanted_card.user.id
        ) if user_wanted_card.name == name
    end
  end
end
