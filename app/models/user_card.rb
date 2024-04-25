class UserCard < ApplicationRecord
  require 'pry-byebug'
  belongs_to :user
  belongs_to :card_version
  has_many :matches

  validates :quantity, presence: true
  validates :condition, presence: true
  validates :language, presence: true
  validates :foil, inclusion: { in: [true, false], message: "can't be blank" }

  enum condition: { poor: "0", played: "1", light_played: "2", good: "3",
    excellent: "4", near_mint: "5", mint: "6" }
  enum language: { français: "0", anglais: "1", allemand: "2", italien: "3", chinois_s: "4",
    chinois_t: "5", japonais: "6", portuguais: "7", russe: "8", corréen: "9" }

  # after_save :check_matches

  def check_matches
    matches.destroy_all
    user_wanted_cards = UserWantedCard.where.not(user_id: user.id)
  
    user_wanted_cards.each do |user_wanted_card|
      # Assumons que la langue de la UserWantedCard est la langue préférée pour la comparaison
      preferred_language = user_wanted_card.language.to_sym # Convertit en symbole si nécessaire
  
      # Obtenez la carte associée à cette UserWantedCard et comparez les noms
      wanted_card = user_wanted_card.card
      my_card = card  # La carte associée à cette UserCard
  
      if wanted_card.name(preferred_language) == my_card.name(preferred_language) && 
         UserCard.conditions[condition].to_i >= UserCard.conditions[user_wanted_card.min_condition].to_i
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
