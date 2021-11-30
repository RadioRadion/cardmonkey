class UserCard < ApplicationRecord
  require 'pry-byebug'
  belongs_to :user
  belongs_to :card
  has_many :matches

  enum condition: { poor: "0", played: "1", light_played: "2", good: "3",
    excellent: "4", near_mint: "5", mint: "6" }
  enum language: { français: "0", anglais: "1", allemand: "2", italien: "3", chinois_s: "4",
    chinois_t: "5", japonais: "6", portuguais: "7", russe: "8", corréen: "9" }

  after_save :check_matches

  def price
    card.price
  end

  def name
    card.name
  end

  def check_matches
    matches.destroy_all
    user_wanted_cards = UserWantedCard.where.not(user_id: user.id)
    user_wanted_cards.each do |user_wanted_card|
      if user_wanted_card.name == name && UserCard.conditions[condition].to_i >= UserCard.conditions[user_wanted_card.min_condition].to_i
        Match.create!(
          user_card_id: id,
          user_wanted_card_id: user_wanted_card.id,
          user_id: user.id,
          user_id_target: user_wanted_card.user.id
          )
      end
    end
  end
end
