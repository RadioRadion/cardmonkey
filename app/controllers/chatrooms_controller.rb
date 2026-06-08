class ChatroomsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :set_chatroom, only: [:show]
  before_action :authorize_chatroom_access, only: [:show]

  def index
    @chatrooms = load_chatrooms

    # Redirect to the most recent chatroom if one exists
    if @chatrooms.any? && !request.xhr?
      redirect_to user_chatroom_path(current_user, @chatrooms.first)
      return
    end
  end

  def show
    @chatrooms = load_chatrooms
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

  def load_chatrooms
    chatrooms = Chatroom
      .includes(:user, :user_invit)
      .where("chatrooms.user_id = :user_id OR chatrooms.user_id_invit = :user_id", user_id: @user.id)
      .left_joins(:messages)
      .select("chatrooms.*, MAX(messages.created_at) as last_message_at")
      .group("chatrooms.id, chatrooms.user_id, chatrooms.user_id_invit, chatrooms.created_at, chatrooms.updated_at")
      .order(Arel.sql("MAX(messages.created_at) DESC NULLS LAST"))
      .to_a

    preload_message_summaries(chatrooms)
    chatrooms
  end

  # Batch-load the last message + unread count per chatroom (avoids N queries
  # in the list view and loading every message into memory).
  def preload_message_summaries(chatrooms)
    ids = chatrooms.map(&:id)
    @last_messages = {}
    @unread_counts = Hash.new(0)
    return if ids.empty?

    last_ids = Message.where(chatroom_id: ids).group(:chatroom_id).maximum(:id)
    @last_messages = Message.where(id: last_ids.values).includes(:user).index_by(&:chatroom_id)
    @unread_counts = Message.where(chatroom_id: ids, read_at: nil)
                            .where.not(user_id: current_user.id)
                            .group(:chatroom_id)
                            .count
    @unread_counts.default = 0
  end

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
