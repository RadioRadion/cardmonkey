class Message < ApplicationRecord
  belongs_to :user
  belongs_to :chatroom, dependent: :destroy
  validates :content, presence: true, allow_blank: false
end
