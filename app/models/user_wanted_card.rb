class UserWantedCard < ApplicationRecord
  include CardConditionManagement

  # Associations
  belongs_to :user
  belongs_to :card
  belongs_to :card_version, optional: true
  has_many :matches, dependent: :destroy

  # Validations
  validates :quantity, :min_condition, :language, presence: true
  validates :foil, inclusion: { in: [true, false], message: "can't be blank" }

  # Énumérations
  enum :min_condition, {
    poor: 'poor',
    played: 'played',
    light_played: 'light_played',
    good: 'good',
    excellent: 'excellent',
    near_mint: 'near_mint',
    mint: 'mint',
    unimportant: 'unimportant'
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
    korean: 'ko',
    any: 'any'
  }, default: 'en'

  # Callbacks - matching runs async (Sidekiq) to avoid blocking the request,
  # mirroring UserCard. Removal notifications are also deferred to a job.
  after_commit :schedule_create_matches, on: :create
  after_commit :schedule_update_matches, on: :update, if: :relevant_attributes_changed?
  before_destroy :snapshot_for_notifications
  after_commit :notify_trade_partners_async, on: :destroy

  # Scopes
  scope :by_min_condition, ->(condition) { where(min_condition: condition) }
  scope :by_language, ->(language) { where(language: language) }
  scope :with_matches, -> { joins(:matches).distinct }
  scope :without_matches, -> { left_joins(:matches).where(matches: { id: nil }) }

  def matches_count
    matches.count
  end

  def potential_matches_count
    MatchFinder.rows_for_user_wanted_card(self).size
  end

  def img_uri
    return card_version.img_uri if card_version.present?
    card.card_versions.first&.img_uri
  end

  # Public method to regenerate matches (async, via Sidekiq)
  def regenerate_matches_async
    UserWantedCardMatchingJob.perform_later(id, :update)
  end

  private

  def schedule_create_matches
    UserWantedCardMatchingJob.perform_later(id, :create)
  end

  def schedule_update_matches
    UserWantedCardMatchingJob.perform_later(id, :update)
  end

  def relevant_attributes_changed?
    saved_change_to_min_condition? ||
    saved_change_to_language? ||
    saved_change_to_card_id? ||
    saved_change_to_card_version_id?
  end

  # Capture the scalars the notification needs before the record disappears.
  def snapshot_for_notifications
    @removal_payload = {
      card_id: card_id,
      language: language,
      user_id: user_id,
      card_name: card&.name,
      username: user&.username
    }
  end

  def notify_trade_partners_async
    return unless @removal_payload

    WantedCardRemovedNotificationJob.perform_later(**@removal_payload)
  end
end
