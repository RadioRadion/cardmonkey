class MessageReaction < ApplicationRecord
  belongs_to :message
  belongs_to :user

  validates :emoji, presence: true
  validates :user_id, uniqueness: { scope: [:message_id, :emoji], message: "a déjà réagi avec cet emoji" }

  ALLOWED_EMOJIS = %w[👍 👎 ❤️ 😂 😮 😢 🎉 🔥].freeze

  validates :emoji, inclusion: { in: ALLOWED_EMOJIS, message: "n'est pas un emoji valide" }

  after_create_commit :broadcast_reaction_added
  after_destroy_commit :broadcast_reaction_removed

  private

  def broadcast_reaction_added
    broadcast_reaction_update
  end

  def broadcast_reaction_removed
    broadcast_reaction_update
  end

  def broadcast_reaction_update
    Turbo::StreamsChannel.broadcast_replace_to(
      message.chatroom,
      target: "message_reactions_#{message_id}",
      partial: "messages/reactions",
      locals: { message: message }
    )
  end
end
