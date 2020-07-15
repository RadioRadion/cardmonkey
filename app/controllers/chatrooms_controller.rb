class ChatroomsController < ApplicationController
  def index
    @chatrooms = current_user.chatrooms.uniq
  end

  def new
    @chatroom = Chatroom.new
  end

  def create
    @chatroom = Chatroom.new(chatroom_params)
    if @chatroom.save!
      redirect_to user_chatrooms_path
    else
      render :new
    end
  end

  def show
    @chatroom = Chatroom.find(params[:id])
    @message = Message.new
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
end
