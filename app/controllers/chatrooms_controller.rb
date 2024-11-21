class ChatroomsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chatroom, only: [:show]
  before_action :authorize_chatroom_access, only: [:show]

  def index
    @chatrooms = current_user_chatrooms.includes(:messages, :user, :user_invit)
                                     .order('messages.created_at DESC')
  end

  def show
    @chatrooms = current_user_chatrooms.includes(:messages)
    @messages = @chatroom.messages.includes(:user).order(created_at: :desc)
    @message = Message.new
    @other_user = @chatroom.other_user(current_user)
    @chatroom.mark_messages_as_read!(current_user) if @chatroom.messages.unread.any?
  end

  private

  def set_chatroom
    @chatroom = Chatroom.find(params[:id])
  end

  def authorize_chatroom_access
    unless chatroom_member?
      redirect_to user_chatrooms_path, alert: 'You do not have access to this chat room.'
    end
  end

  def chatroom_member?
    @chatroom.user_id == current_user.id || @chatroom.user_id_invit == current_user.id
  end

  def current_user_chatrooms
    Chatroom.where(user_id: current_user.id).or(Chatroom.where(user_id_invit: current_user.id))
  end
end
