# Notifies trade partners that a user removed a wanted card that was part of an
# active trade. Runs the (potentially heavy, cross-user) lookup off the request
# cycle. Receives only scalars snapshotted before the record was destroyed.
class WantedCardRemovedNotificationJob < ApplicationJob
  queue_as :default

  def perform(card_id:, language:, user_id:, card_name:, username:)
    languages = language == 'any' ? UserCard.languages.keys : language

    matching_cards = UserCard.joins(card_version: :card)
                             .where(cards: { id: card_id })
                             .where(language: languages)

    matching_cards.find_each do |matching_card|
      matching_card.trades.active.each do |trade|
        next if trade.user_id == matching_card.user_id && trade.user_id_invit != user_id
        next if trade.user_id_invit == matching_card.user_id && trade.user_id != user_id

        notification_message = I18n.t('notifications.trade.wanted_card_removed',
                                      card_name: card_name, username: username)
        chat_message = I18n.t('notifications.trade.wanted_card_removed_chat',
                              card_name: card_name, username: username)

        Notification.create_notification(matching_card.user_id, notification_message)
        Trade.save_message(user_id, matching_card.user_id, chat_message)
      end
    end
  end
end
