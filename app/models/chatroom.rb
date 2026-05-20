class Chatroom < ApplicationRecord
  belongs_to :user
  belongs_to :user_invit, class_name: 'User', foreign_key: 'user_id_invit'
  
  has_many :messages, -> { ordered }, dependent: :destroy
  has_many :notifications, dependent: :destroy

  validates :user_id, uniqueness: { scope: :user_id_invit }

  scope :for_user, ->(user) { where(user: user).or(where(user_id_invit: user)) }
  scope :ordered_by_recent_message, -> { 
    left_joins(:messages)
      .group(:id)
      .order('MAX(messages.created_at) DESC NULLS LAST')
  }
  scope :with_unread_messages, ->(user) {
    joins(:messages)
      .where.not(messages: { user_id: user.id })
      .where(messages: { read_at: nil })
      .distinct
  }

  def self.between(user1, user2)
    where(user: user1, user_id_invit: user2)
      .or(where(user: user2, user_id_invit: user1))
      .first_or_create do |chatroom|
        chatroom.user = user1
        chatroom.user_id_invit = user2.id
      end
  end

  def participant?(user)
    user_id == user.id || user_id_invit == user.id
  end

  def other_user(current_user)
    current_user == user ? user_invit : user
  end

  def unread_count_for(user)
    messages.where.not(user: user).where(read_at: nil).count
  end

  def mark_as_read_for(user)
    messages.where.not(user: user).where(read_at: nil).update_all(read_at: Time.current)
  end

  def mark_as_unread_for(user)
    last_message = messages.last
    return unless last_message && last_message.user != user
    
    last_message.update_column(:read_at, nil)
  end

  def last_message
    messages.last
  end

  def last_message_preview
    last = last_message
    return "Pas de messages" unless last

    if last.trade_message?
      "#{last.user.username} a proposé un échange"
    elsif last.attachments.any?
      "#{last.user.username} a envoyé #{last.attachments.count} fichier(s)"
    else
      last.content.truncate(50)
    end
  end

  def active_users
    User.where(id: [user_id, user_id_invit])
         .where("last_seen_at > ?", 5.minutes.ago)
  end

  def typing_users
    Redis.current.smembers("chatroom:#{id}:typing").map(&:to_i)
  end

  def set_typing(user_id, is_typing)
    key = "chatroom:#{id}:typing"
    if is_typing
      Redis.current.sadd(key, user_id)
      Redis.current.expire(key, 10) # Expire after 10 seconds of inactivity
    else
      Redis.current.srem(key, user_id)
    end
  end

  private
end
