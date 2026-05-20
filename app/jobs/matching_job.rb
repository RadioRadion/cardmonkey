class MatchingJob < ApplicationJob
  queue_as :default

  # Retry on transient errors
  retry_on ActiveRecord::Deadlocked, wait: 5.seconds, attempts: 3
  retry_on ActiveRecord::LockWaitTimeout, wait: 5.seconds, attempts: 3

  def perform(user_card_id, action = :create)
    user_card = UserCard.find_by(id: user_card_id)
    return unless user_card

    case action.to_sym
    when :create
      create_matches_for(user_card)
    when :update
      update_matches_for(user_card)
    when :destroy
      # Matches are already destroyed via dependent: :destroy
      Rails.logger.info("MatchingJob: Matches for UserCard #{user_card_id} already cleaned up")
    end
  end

  private

  def create_matches_for(user_card)
    potential_matches = find_potential_matches(user_card)
    return if potential_matches.empty?

    matches_to_create = build_matches(user_card, potential_matches)
    Match.insert_all(matches_to_create) if matches_to_create.any?

    Rails.logger.info("MatchingJob: Created #{matches_to_create.size} matches for UserCard #{user_card.id}")
  end

  def update_matches_for(user_card)
    user_card.matches.destroy_all
    create_matches_for(user_card)
  end

  def find_potential_matches(user_card)
    card_condition_value = UserCard::CONDITION_ORDER[user_card.condition] || 0

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
      .where.not(user_id: user_card.user_id)
      .where(card_id: user_card.card_version.card_id)
      .where("user_wanted_cards.language = 'any' OR user_wanted_cards.language = ?", user_card.language)
      .where("? >= (#{condition_case_sql})", card_condition_value)
      .select(:id, :user_id)
  end

  def build_matches(user_card, potential_matches)
    current_time = Time.current

    potential_matches.map do |wanted_card|
      {
        user_card_id: user_card.id,
        user_wanted_card_id: wanted_card.id,
        user_id: user_card.user_id,
        user_id_target: wanted_card.user_id,
        created_at: current_time,
        updated_at: current_time
      }
    end
  end
end
