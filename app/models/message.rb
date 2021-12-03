class Message < ApplicationRecord
  belongs_to :user
  belongs_to :chatroom
  validates :content, presence: true, allow_blank: false

  after_save :create_notification

  def create_notification

  end
end
