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
      created = MatchFinder.create_for_user_card(user_card)
      Rails.logger.info("MatchingJob: created #{created} matches for UserCard #{user_card.id}")
    when :update
      user_card.matches.destroy_all
      MatchFinder.create_for_user_card(user_card)
    when :destroy
      # Matches are already destroyed via dependent: :destroy
      Rails.logger.info("MatchingJob: Matches for UserCard #{user_card_id} already cleaned up")
    end
  end
end
