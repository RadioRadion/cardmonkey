class Chatroom < ApplicationRecord
  has_many :messages, dependent: :destroy
  validates :user_id, presence: true
  validates :user_id_invit, presence: true
end
