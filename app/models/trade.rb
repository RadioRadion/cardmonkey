class Trade < ApplicationRecord
  belongs_to :user
  has_many :trade_user_cards, dependent: :destroy
  has_many :user_cards, through: :trade_user_cards

  scope :pending, -> { where(status: "pending") }
  scope :accepted, -> { where(status: "accepted") }
  scope :done, -> { where(status: "done") }
  scope :active, -> { where(status: ['pending', 'accepted']).where.not(accepted_at: nil) }

  validates :status, presence: true

  enum status: { pending: "0", accepted: "1", done: "2" }

  def self.save_message(current_user_id, other_user_id, content)
    first_chat = Chatroom.where(user_id: current_user_id, user_id_invit: other_user_id).first
    second_chat = Chatroom.where(user_id: other_user_id, user_id_invit: current_user_id).first

    if !first_chat.nil?
      Message.new(content: content, user_id: current_user_id, chatroom_id: first_chat.id).save!
    elsif !second_chat.nil?
      Message.new(content: content, user_id: current_user_id, chatroom_id: second_chat.id).save!
    else
      chatroom = Chatroom.create!(user_id: current_user_id, user_id_invit: other_user_id)
      Message.create!(content: content, user_id: current_user_id, chatroom_id: @chatroom.id)
    end
  end
end
