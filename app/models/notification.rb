class Notification < ApplicationRecord
  # Relations
  belongs_to :user

  # Validations
  validates :content, presence: true
  validates :status, presence: true, inclusion: { in: %w[unread read] }

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
  scope :this_week, -> { where('created_at >= ?', Time.current.beginning_of_week) }
  scope :by_type, ->(type) { where('content ILIKE ?', "%#{type}%") }

  # Callbacks
  after_create_commit -> { broadcast_notification }
  after_update_commit -> { broadcast_update }

  # Class methods
  def self.create_notification(recipient_id, message, type = nil)
    create!(
      user_id: recipient_id,
      content: message,
      status: :unread,
      notification_type: type
    )
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("Failed to create notification: #{e.message}")
    nil
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