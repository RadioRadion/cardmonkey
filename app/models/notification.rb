class Notification < ApplicationRecord
  belongs_to :user

  validates :content, :status, presence: true

  scope :unread, -> { where(status: 'unread') }
  scope :recent, -> { order(created_at: :desc).limit(5) }

  def self.create_notification(recipient_id, message)
    create(
      user_id: recipient_id,
      content: message,
      status: 'unread'
    )
  end

  def mark_as_read!
    update!(status: 'read')
  end
end
