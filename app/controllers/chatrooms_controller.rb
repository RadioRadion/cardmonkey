class ChatroomsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :set_chatroom, only: [:show]
  before_action :authorize_chatroom_access, only: [:show]

  def index
    @chatrooms = Chatroom
      .includes(:messages, :user, :user_invit)
      .where("chatrooms.user_id = :user_id OR chatrooms.user_id_invit = :user_id", user_id: @user.id)
      .left_joins(:messages)
      .select("chatrooms.*, MAX(messages.created_at) as last_message_at")
      .group("chatrooms.id, chatrooms.user_id, chatrooms.user_id_invit, chatrooms.created_at, chatrooms.updated_at")
      .order(Arel.sql("MAX(messages.created_at) DESC NULLS LAST"))
  end

  def show
    # Load all chatrooms for the sidebar with proper eager loading
    @chatrooms = Chatroom
      .includes(:messages, :user, :user_invit)
      .where("chatrooms.user_id = :user_id OR chatrooms.user_id_invit = :user_id", user_id: @user.id)
      .left_joins(:messages)
      .select("chatrooms.*, MAX(messages.created_at) as last_message_at")
      .group("chatrooms.id, chatrooms.user_id, chatrooms.user_id_invit, chatrooms.created_at, chatrooms.updated_at")
      .order(Arel.sql("MAX(messages.created_at) DESC NULLS LAST"))

    # Load messages and ensure other_user is properly set
    @messages = @chatroom.messages.includes(:user).order(created_at: :asc)
    @message = Message.new
    @other_user = @chatroom.other_user(current_user)

    if @other_user.nil?
      redirect_to user_chatrooms_path(current_user), alert: "L'autre utilisateur n'est plus disponible."
      return
    end

    # Mark unread messages as read
    unread_messages = @chatroom.messages.unread_for(current_user)
    if unread_messages.any?
      unread_messages.update_all(read_at: Time.current)
    end
  end

  def create
    @chatroom = Chatroom.new(chatroom_params)
    @chatroom.user = current_user

    if @chatroom.save
      redirect_to user_chatroom_path(current_user, @chatroom), notice: 'Conversation créée avec succès.'
    else
      redirect_to user_chatrooms_path(current_user), alert: 'Impossible de créer la conversation.'
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
    unless @user == current_user
      redirect_to user_chatrooms_path(current_user), alert: "Vous ne pouvez pas accéder aux messages d'autres utilisateurs."
    end
  end

  def set_chatroom
    @chatroom = @user.chatrooms.includes(:user, :user_invit).find(params[:id])
  end

  def authorize_chatroom_access
    unless chatroom_member?
      redirect_to user_chatrooms_path(current_user), alert: "Vous n'avez pas accès à cette conversation."
    end
  end

  def chatroom_member?
    @chatroom.user_id == current_user.id || @chatroom.user_id_invit == current_user.id
  end

  def chatroom_params
    params.require(:chatroom).permit(:user_id_invit)
  end
end
