class Trade < ApplicationRecord
  belongs_to :user
  has_many :card_trades
  has_many :cards, through: :card_trades

  private

  def self.save_message(current_user_id, other_user_id, content)
    first_chat = Chatroom.where(user_id: current_user_id, user_id_invit: other_user_id).first
    second_chat = Chatroom.where(user_id: other_user_id, user_id_invit: current_user_id).first

    if !first_chat.nil?
      Message.new(content: content, user_id: current_user_id, chatroom_id: first_chat.id).save!
    elsif !second_chat.nil?
      Message.new(content: content, user_id: current_user_id, chatroom_id: second_chat.id).save!
    else
      chatroom = Chatroom.new(user_id: current_user_id, user_id_invit: other_user_id)
      chatroom.save!
      Message.new(content: content, user_id: current_user_id, chatroom_id: @chatroom.id).save!
    end
  end
end
