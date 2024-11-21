class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chatroom
  before_action :authorize_chatroom_access

  def create
    @message = @chatroom.messages.build(message_params)
    @message.user = current_user

    if @message.save
      broadcast_message
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to user_chatroom_path(current_user, @chatroom) }
      end
    else
      respond_to do |format|
        format.turbo_stream { 
          render turbo_stream: turbo_stream.replace(
            'new_message_form',
            partial: 'messages/form',
            locals: { message: @message, chatroom: @chatroom }
          )
        }
        format.html { render 'chatrooms/show' }
      end
    end
  end

  private

  def set_chatroom
    @chatroom = Chatroom.find(params[:chatroom_id])
  end

  def authorize_chatroom_access
    unless chatroom_member?
      respond_to do |format|
        format.turbo_stream { head :forbidden }
        format.html { 
          redirect_to user_chatrooms_path, 
          alert: 'You do not have access to this chat room.' 
        }
      end
    end
  end

  def chatroom_member?
    @chatroom.user_id == current_user.id || @chatroom.user_id_invit == current_user.id
  end

  def message_params
    params.require(:message).permit(:content)
  end

  def broadcast_message
    ChatroomChannel.broadcast_to(
      @chatroom,
      turbo_stream.append(
        'messages',
        partial: 'messages/message',
        locals: { message: @message }
      )
    )
  end
end
