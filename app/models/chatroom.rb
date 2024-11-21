class Chatroom < ApplicationRecord
  has_many :messages, dependent: :destroy
  belongs_to :user
  belongs_to :user_invit, class_name: 'User', foreign_key: 'user_id_invit'

  validates :user_id, :user_id_invit, presence: true
  validate :users_are_different
  validate :chatroom_uniqueness

  scope :for_user, ->(user_id) { 
    where(user_id: user_id).or(where(user_id_invit: user_id))
  }

  def other_user(current_user)
    current_user.id == user_id ? user_invit : user
  end

  def unread_messages_count(user)
    messages.where.not(user: user).unread.count
  end

  def mark_messages_as_read!(user)
    messages.where.not(user: user).unread.update_all(read_at: Time.current)
  end

  private

  def users_are_different
    if user_id == user_id_invit
      errors.add(:base, "You can't create a chat room with yourself")
    end
  end

  def chatroom_uniqueness
    existing_chatroom = Chatroom.where(
      "(user_id = :user_id AND user_id_invit = :user_id_invit) OR 
       (user_id = :user_id_invit AND user_id_invit = :user_id)",
      user_id: user_id, user_id_invit: user_id_invit
    ).where.not(id: id).exists?

    if existing_chatroom
      errors.add(:base, "A chat room between these users already exists")
    end
  end
end
