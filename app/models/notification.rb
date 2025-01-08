class Notification < ApplicationRecord
  # Relations
  belongs_to :user

  # Validations
  validates :content, presence: true
  validates :status, presence: true

  # Enums
  enum status: {
    unread: 'unread',
    read: 'read'
  }, _default: :unread

  # Scopes
  scope :unread, -> { where(status: :unread) }
  scope :read, -> { where(status: :read) }
  scope :recent, -> { order(created_at: :desc).limit(5) }
  scope :today, -> { where('created_at >= ?', Time.current.beginning_of_day) }
  scope :this_week, -> { where('created_at >= ?', 1.week.ago) }
  scope :by_type, ->(type) { where('content ILIKE ?', "%#{type}%") }

  # Callbacks
  after_create_commit -> { broadcast_notification }
  after_update_commit -> { broadcast_update }

  # Class methods
  def self.create_notification(recipient_id, message, type = nil, resource_id = nil)
    create!(
      user_id: recipient_id,
      content: message,
      status: :unread,
      notification_type: type,
      resource_id: resource_id
    )
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("Failed to create notification: #{e.message}")
    nil
  end

  def self.create_trade_notification(recipient_id, trade_id, message)
    create_notification(
      recipient_id,
      message,
      'trade',
      trade_id
    )
  end

  def self.mark_all_as_read(user_id)
    where(user_id: user_id, status: :unread)
      .update_all(status: :read, read_at: Time.current)
  end

  # Instance methods
  def mark_as_read!
    return if read?
    
    update!(
      status: :read,
      read_at: Time.current
    )
  end

  def age_in_words
    time_ago_in_words(created_at)
  end

  def read?
    status == 'read'
  end

  def unread?
    status == 'unread'
  end

  def clickable?
    resource_path.present?
  end

  def resource_path
    case notification_type
    when 'trade'
      "/trades/#{resource_id}"
    when 'message'
      "/chatrooms/#{resource_id}"
    when 'match'
      if content.match?(/wanted card/i)
        "/user_wanted_cards"
      else
        "/user_cards"
      end
    else
      nil
    end
  end

  private

  def broadcast_notification
    broadcast_append_to(
      "user_notifications_#{user_id}",
      target: 'notifications',
      partial: 'notifications/notification',
      locals: { notification: self }
    )
  end

  def broadcast_update
    broadcast_replace_to(
      "user_notifications_#{user_id}",
      target: self,
      partial: 'notifications/notification',
      locals: { notification: self }
    )
  end
end
