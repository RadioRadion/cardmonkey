class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?
  has_one_attached :avatar

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  # Chatroom associations
  has_many :sent_chatrooms, class_name: 'Chatroom', foreign_key: 'user_id'
  has_many :received_chatrooms, class_name: 'Chatroom', foreign_key: 'user_id_invit'
  has_many :messages
  
  # Other associations
  has_many :trades
  has_many :user_cards
  has_many :cards, through: :user_cards
  has_many :user_wanted_cards
  has_many :matches
  has_many :notifications

  enum preference: { value_based: 0, quantity_based: 1 }

  def chatrooms
    Chatroom.where('user_id = :user_id OR user_id_invit = :user_id', user_id: id)
  end

  def top_matching_users(limit = 10)
    User.find_by_sql([<<-SQL, { user_id: id, limit: limit }])
      WITH match_counts AS (
        SELECT 
          CASE 
            WHEN user_id = :user_id THEN user_id_target
            WHEN user_id_target = :user_id THEN user_id
          END AS matched_user_id,
          COUNT(*) as match_count
        FROM matches
        WHERE user_id = :user_id OR user_id_target = :user_id
        GROUP BY 
          CASE 
            WHEN user_id = :user_id THEN user_id_target
            WHEN user_id_target = :user_id THEN user_id
          END
      )
      SELECT 
        users.*,
        match_counts.match_count,
        (
          SELECT COUNT(DISTINCT cards.id)
          FROM matches
          JOIN user_cards ON matches.user_card_id = user_cards.id
          JOIN card_versions ON user_cards.card_version_id = card_versions.id
          JOIN cards ON card_versions.card_id = cards.id
          WHERE 
            (matches.user_id = :user_id AND matches.user_id_target = users.id)
            OR
            (matches.user_id = users.id AND matches.user_id_target = :user_id)
        ) as unique_cards_count
      FROM users
      JOIN match_counts ON users.id = match_counts.matched_user_id
      ORDER BY match_count DESC, users.username
      LIMIT :limit
    SQL
  end

  # Trouve les cartes qui matchent avec un utilisateur spécifique
  def matching_cards_with_user(other_user_id)
    Match.joins(user_card: { card_version: :card })
        .where(
          '(matches.user_id = ? AND matches.user_id_target = ?) OR (matches.user_id = ? AND matches.user_id_target = ?)',
          id, other_user_id, other_user_id, id
        )
        .select('cards.*, matches.*, user_cards.condition, user_cards.language')
        .distinct
  end

  def all_trades
    Trade.where('user_id = ? OR user_id_invit = ?', id, id)
  end

  # Statistiques de matching
  def matching_stats
    {
      total_matches: Match.where(user_id: id).or(Match.where(user_id_target: id)).count,
      unique_matched_users: top_matching_users.size,
      matches_by_condition: Match.joins(user_card: :card_version)
                               .where(user_id: id)
                               .group('user_cards.condition')
                               .count,
      matches_by_language: Match.joins(user_card: :card_version)
                              .where(user_id: id)
                              .group('user_cards.language')
                              .count
    }
  end

  def avatar_thumbnail
    if avatar.attached?
      avatar
    else
      # Version plus simple avec une image statique
      "https://via.placeholder.com/64"
    end
  end
end
