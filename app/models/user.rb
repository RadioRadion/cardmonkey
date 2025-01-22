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
  
  # Trade associations
  has_many :trades
  has_many :received_trades, class_name: 'Trade', foreign_key: 'user_id_invit'
  has_many :modified_trades, class_name: 'Trade', foreign_key: 'last_modifier_id'
  
  # Other associations
  has_many :user_cards
  has_many :card_versions, through: :user_cards
  has_many :cards, through: :card_versions
  has_many :user_wanted_cards
  has_many :matches
  has_many :notifications

  enum preference: { value_based: 0, quantity_based: 1 }

  before_validation :set_default_username, on: :create

  def all_trades
    Trade.where('user_id = ? OR user_id_invit = ?', id, id)
  end

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

  def chatrooms
    Chatroom.where('user_id = :user_id OR user_id_invit = :user_id', user_id: id)
  end

  private

  def set_default_username
    return if username.present?
    self.username = email.split('@').first if email.present?
  end

  def top_matching_users(limit = 10)
    User.find_by_sql([<<-SQL, { user_id: id, limit: limit }])
      WITH match_counts AS (
        SELECT 
          CASE 
            WHEN matches.user_id = :user_id THEN matches.user_id_target
            WHEN matches.user_id_target = :user_id THEN matches.user_id
          END AS matched_user_id,
          COUNT(*) as match_count
        FROM matches
        WHERE (matches.user_id = :user_id OR matches.user_id_target = :user_id)
          AND (matches.user_id IS NOT NULL AND matches.user_id_target IS NOT NULL)
        GROUP BY 
          CASE 
            WHEN matches.user_id = :user_id THEN matches.user_id_target
            WHEN matches.user_id_target = :user_id THEN matches.user_id
          END
      )
      SELECT 
        users.*,
        match_counts.match_count
      FROM users
      INNER JOIN match_counts ON users.id = match_counts.matched_user_id
      ORDER BY match_counts.match_count DESC, users.username
      LIMIT :limit
    SQL
  end

  def matching_cards_with_user(other_user_id)
    Card.joins(card_versions: { user_cards: :matches })
        .where(
          '(matches.user_id = :user_id AND matches.user_id_target = :other_user_id) OR (matches.user_id = :other_user_id AND matches.user_id_target = :user_id)',
          user_id: id, other_user_id: other_user_id
        )
        .select('cards.*, user_cards.condition, user_cards.language')
        .distinct
        .order('cards.id')
  end

end
