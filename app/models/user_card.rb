class UserCard < ApplicationRecord
  include CardConditionManagement

  belongs_to :user
  belongs_to :card_version
  has_many :matches, dependent: :destroy
  has_many :trade_user_cards, dependent: :delete_all
  has_many :trades, through: :trade_user_cards

  # Condition ordering lives in CardConditionManagement::CONDITION_ORDER
  # (single source of truth, shared with UserWantedCard and MatchFinder).

  # Validations
  validates :quantity, :condition, :language, presence: true
  validates :foil, inclusion: { in: [true, false], message: "can't be blank" }

  # Énumérations
  enum :condition, {
    poor: 'poor',
    played: 'played',
    light_played: 'light_played',
    good: 'good',
    excellent: 'excellent',
    near_mint: 'near_mint',
    mint: 'mint'
  }, default: 'good'

  enum :language, {
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
  }, default: 'en'

  # Callbacks - use async jobs for matching to avoid blocking requests
  after_commit :schedule_create_matches, on: :create
  after_commit :schedule_update_matches, on: :update, if: :relevant_attributes_changed?
  before_destroy :notify_trade_partners

  # Public method to regenerate matches (async, via Sidekiq)
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

  def relevant_attributes_changed?
    saved_change_to_condition? ||
    saved_change_to_language? ||
    saved_change_to_card_version_id?
  end
end
