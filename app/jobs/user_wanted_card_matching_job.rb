class UserWantedCardMatchingJob < ApplicationJob
  queue_as :default

  retry_on ActiveRecord::Deadlocked, wait: 5.seconds, attempts: 3
  retry_on ActiveRecord::LockWaitTimeout, wait: 5.seconds, attempts: 3

  def perform(user_wanted_card_id, action = :create)
    user_wanted_card = UserWantedCard.find_by(id: user_wanted_card_id)
    return unless user_wanted_card

    case action.to_sym
    when :create
      MatchFinder.create_for_user_wanted_card(user_wanted_card)
    when :update
      user_wanted_card.matches.destroy_all
      MatchFinder.create_for_user_wanted_card(user_wanted_card)
    when :destroy
      # Matches already removed via dependent: :destroy
    end
  end
end
