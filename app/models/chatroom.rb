class Chatroom < ApplicationRecord
  has_many :messages, dependent: :destroy
  validates :user_id, presence: true
  validates :user_id_invit, presence: true

  scope :chatrooms_ordered, lambda { |user|
    where(user_id: user).or(Chatroom.where(user_id_invit: user))
    .joins('LEFT JOIN messages ON messages.chatroom_id = chatrooms.id')
    .group('chatrooms.id')
    .order('MAX(messages.created_at) DESC')
}

  def new_messages(user_id)
    Message
      .where(chatroom_id: self.id, is_new: true)
        .where.not(user_id: user_id)
  end
end

