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
  enum min_condition: {
    poor: 'poor',
    played: 'played',
    light_played: 'light_played',
    good: 'good',
    excellent: 'excellent',
    near_mint: 'near_mint',
    mint: 'mint',
    unimportant: 'unimportant'
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
    korean: 'ko',
    any: 'any'
  }, _default: 'en'

  # Callbacks
  after_create :create_matches
  after_update :update_matches, if: :relevant_attributes_changed?
  before_destroy :notify_trade_partners

  # Scopes
  scope :by_min_condition, ->(condition) { where(min_condition: condition) }
  scope :by_language, ->(language) { where(language: language) }
  scope :with_matches, -> { joins(:matches).distinct }
  scope :without_matches, -> { left_joins(:matches).where(matches: { id: nil }) }

  def matches_count
    matches.count
  end

  def potential_matches_count
    find_potential_matches.count
  end

  def img_uri
    card_version&.img_uri || card.card_versions.first&.img_uri
  end

  private

  def notify_trade_partners
    # Trouve tous les trades actifs où cette carte est potentiellement impliquée
    matching_cards = UserCard.joins(card_version: :card)
                           .where(cards: { id: card_id })
                           .where(language: language == 'any' ? UserCard.languages.keys : language)
    
    return if matching_cards.empty?

    # Pour chaque carte correspondante, vérifie si elle est dans un trade actif
    matching_cards.each do |matching_card|
      matching_card.trades.active.each do |trade|
        # Si le trade est avec l'utilisateur qui possède la carte
        next if trade.user_id == matching_card.user_id && trade.user_id_invit != user_id
        next if trade.user_id_invit == matching_card.user_id && trade.user_id != user_id

        # Notifie le propriétaire de la carte que la carte n'est plus recherchée
        notification_message = I18n.t('notifications.trade.wanted_card_removed',
                                    card_name: card.name,
                                    username: user.username)
        chat_message = I18n.t('notifications.trade.wanted_card_removed_chat',
                             card_name: card.name,
                             username: user.username)

        # Crée la notification
        Notification.create_notification(matching_card.user_id, notification_message)

        # Ajoute un message dans le chat de l'échange
        Trade.save_message(user.id, matching_card.user_id, chat_message)
      end
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
    saved_change_to_min_condition? ||
    saved_change_to_language? ||
    saved_change_to_card_id? ||
    saved_change_to_card_version_id?
  end

  def find_potential_matches
    base_query = UserCard
      .joins(card_version: :card)
      .where.not(user_id: user_id)
      .where(cards: { id: card_id })

    base_query = apply_language_condition(base_query)
    apply_condition_requirement(base_query)
  end

  def apply_language_condition(query)
    return query if language == 'any'
    query.where(language: language)
  end

  def apply_condition_requirement(query)
    return query if min_condition == 'unimportant'
    
    condition_index = CONDITION_ORDER.index(min_condition)
    return query if condition_index.nil?
    
    valid_conditions = CONDITION_ORDER[condition_index..]
    query.where(condition: valid_conditions)
  end

  def build_matches(potential_matches)
    current_time = Time.current

    potential_matches.map do |user_card|
      {
        user_card_id: user_card.id,
        user_wanted_card_id: id,
        user_id: user_card.user_id,
        user_id_target: user_id,
        created_at: current_time,
        updated_at: current_time
      }
    end
  end
end
