class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :trades
  has_many :messages
  has_many :chatrooms, through: :messages
  has_many :user_cards
  has_many :cards, through: :user_cards
  has_many :user_wanted_cards
  has_many :matches
  has_many :notifications

  enum preference: { value_based: 0, quantity_based: 1 }

  # Trouver des correspondances pour les cartes souhaitées
  def find_card_matches
    # Récupérer la liste de souhaits de l'utilisateur
    wanted_card_ids = user_wanted_cards.pluck(:card_id)

    # Trouver les correspondances dans les collections d'autres utilisateurs
    matches = UserCard.where(card_id: wanted_card_ids)
                      .where.not(user_id: id)
                      .includes(:user, :card)

    # Filtrer les correspondances basées sur la préférence de l'utilisateur (nombre de cartes ou valeur totale)
    matches = sort_matches(matches)

    # Optionnel : Filtrer les correspondances basées sur la géolocalisation
    # matches = filter_by_location(matches)

    matches
  end

  private

  # Trier les correspondances en fonction de la préférence de l'utilisateur
  def sort_matches(matches)
    case preference
    when 'value'
      matches.sort_by { |match| -match.card.price }
    when 'quantity'
      matches.group_by(&:user_id).sort_by { |_, user_matches| -user_matches.count }
    else
      matches
    end
  end

  # Filtrer les correspondances en fonction de la géolocalisation (si nécessaire)
  def filter_by_location(matches)
    # Implémentation dépend de la façon dont la localisation est gérée dans l'application
  end

  def group_matches
    users = User.near(address, area)
      results = []
      users.each do |user|
        matches = Match
                    .where(user_id: id, user_id_target: user.id)
                    .or(Match.where(user_id: user.id, user_id_target: id))
        total = matches.count
        results << {total: total, matches: matches, user: user} if user.id != id
      end
      results.sort_by { |i| i[:total] }.reverse
  end

end
