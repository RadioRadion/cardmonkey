class Notification < ApplicationRecord
  belongs_to :user

  enum status: { open: "0", closed: "1" }

  def self.create_notification(user_id, content)
    Notification.create!(user_id: user_id, content: content, status: :open)
  end
end
