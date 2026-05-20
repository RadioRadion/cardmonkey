class UserCard < ApplicationRecord
  include CardConditionManagement

  belongs_to :user
  belongs_to :card_version
  has_many :matches, dependent: :destroy
  has_many :trade_user_cards, dependent: :delete_all
  has_many :trades, through: :trade_user_cards

  # Condition quality ordering (worst to best)
  CONDITION_ORDER = {
    'poor' => 0,
    'played' => 1,
    'light_played' => 2,
    'good' => 3,
    'excellent' => 4,
    'near_mint' => 5,
    'mint' => 6
  }.freeze

  # Validations
  validates :quantity, :condition, :language, presence: true
  validates :foil, inclusion: { in: [true, false], message: "can't be blank" }

  # Énumérations
  enum condition: {
    poor: 'poor',
    played: 'played',
    light_played: 'light_played',
    good: 'good',
    excellent: 'excellent',
    near_mint: 'near_mint',
    mint: 'mint'
  }, _default: 'good'

  enum language: {
    french: 'fr',
    english: 'en',
    german: 'de',
    italian: 'it',
    simplified_chinese: 'zhs',
    traditional_chinese: 'zht',
    japanese: 'ja',
    portuguese: 'pt',
    russian: 'ru',
    korean: 'ko'
  }, _default: 'en'

  # Callbacks - use async jobs for matching to avoid blocking requests
  after_commit :schedule_create_matches, on: :create
  after_commit :schedule_update_matches, on: :update, if: :relevant_attributes_changed?
  before_destroy :notify_trade_partners

  # Public method to regenerate matches (sync)
  def regenerate_matches
    update_matches
  end

  # Public method to regenerate matches (async)
  def regenerate_matches_async
    MatchingJob.perform_later(id, :update)
  end

  private

  def schedule_create_matches
    MatchingJob.perform_later(id, :create)
  end

  def schedule_update_matches
    MatchingJob.perform_later(id, :update)
  end

  def notify_trade_partners
    affected_trades = trades.active

    affected_trades.each do |trade|
      partner = trade.partner_for(user)
      next unless partner

      card_name = card_version.card.name
      notification_message = I18n.t('notifications.trade.card_removed', card_name: card_name)
      chat_message = I18n.t('notifications.trade.card_removed_chat', card_name: card_name)
      
      Notification.create_notification(partner.id, notification_message)
      Trade.save_message(user.id, partner.id, chat_message)
    end
  end

  def create_matches
    potential_matches = find_potential_matches
    return if potential_matches.empty?

    matches_to_create = build_matches(potential_matches)
    Match.insert_all(matches_to_create) if matches_to_create.any?
  end

  def update_matches
    matches.destroy_all
    create_matches
  end

  def relevant_attributes_changed?
    saved_change_to_condition? || 
    saved_change_to_language? || 
    saved_change_to_card_version_id?
  end

  def find_potential_matches
    # Get ordinal value for this card's condition
    card_condition_value = CONDITION_ORDER[condition] || 0

    # SQL CASE for converting condition strings to ordinal values
    condition_case_sql = <<-SQL
      CASE COALESCE(user_wanted_cards.min_condition, 'poor')
        WHEN 'poor' THEN 0
        WHEN 'played' THEN 1
        WHEN 'light_played' THEN 2
        WHEN 'good' THEN 3
        WHEN 'excellent' THEN 4
        WHEN 'near_mint' THEN 5
        WHEN 'mint' THEN 6
        ELSE 0
      END
    SQL

    UserWantedCard
      .joins(:card)
      .where.not(user_id: user_id)
      .where(card_id: card_version.card_id)
      .where("user_wanted_cards.language = 'any' OR user_wanted_cards.language = ?", language)
      .where("? >= (#{condition_case_sql})", card_condition_value)
      .select(:id, :user_id)
  end

  def build_matches(potential_matches)
    current_time = Time.current
    
    potential_matches.map do |wanted_card|
      {
        user_card_id: id,
        user_wanted_card_id: wanted_card.id,
        user_id: user_id,
        user_id_target: wanted_card.user_id,
        created_at: current_time,
        updated_at: current_time
      }
    end
  end
end
