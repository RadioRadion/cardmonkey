class MessageReaction < ApplicationRecord
  belongs_to :message
  belongs_to :user

  validates :emoji, presence: true
  validates :message_id, uniqueness: { scope: [:user_id, :emoji] }

  after_create_commit :notify_reaction
  after_destroy_commit :notify_reaction

  private

  def notify_reaction
    return if message.user == user

    Notification.create(
      recipient: message.user,
      actor: user,
      action: destroyed? ? 'removed_reaction' : 'reacted',
      notifiable: message,
      metadata: { emoji: emoji }
    )
  end
end
