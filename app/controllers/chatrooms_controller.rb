class ChatroomsController < ApplicationController
  def index
    @chatrooms = Chatroom.chatrooms_ordered(current_user)
    @first_chatroom = @chatrooms.first
    @message = Message.new
    mark_messages_as_read(@first_chatroom)
  end

  def new
    @chatroom = Chatroom.new
  end

  def create
    @chatroom = Chatroom.new(chatroom_params)
    @chatroom.user = current_user

    if @chatroom.save!
      redirect_to user_chatrooms_path
    else
      render :new
    end
  end

  def show
    @chatrooms = Chatroom.chatrooms_ordered(current_user)
    @chatroom = Chatroom.find(params[:id])
    @message = Message.new
    mark_messages_as_read(@chatroom)
  end

  def destroy
    @chatroom = Chatroom.find(params[:id])
    @chatroom.destroy
    redirect_to user_chatroom_path
  end

  private

  def chatroom_params
    params.require(:chatroom).permit(:name)
  end

  def mark_messages_as_read(chatroom)
    chatroom.messages
      .where(is_new: true)
      .update_all(is_new: false, read_date: DateTime.now)
  end
end
