class ChatroomChannel < ApplicationCable::Channel
  def subscribed
    @chatroom = Chatroom.find(params[:id])
    if authorized?
      stream_for @chatroom
      broadcast_user_status('online')
    else
      reject
    end
  rescue ActiveRecord::RecordNotFound
    reject
  end

  def unsubscribed
    if @chatroom
      broadcast_user_status('offline')
      clear_typing_status
    end
  end

  def typing(data)
    return unless authorized?
    
    ChatroomChannel.broadcast_to(
      @chatroom,
      type: 'typing_status',
      user_id: current_user.id,
      username: current_user.username,
      is_typing: data['typing']
    )
  end

  private

  def authorized?
    @chatroom.user_id == current_user.id || @chatroom.user_id_invit == current_user.id
  end

  def broadcast_user_status(status)
    ChatroomChannel.broadcast_to(
      @chatroom,
      type: 'user_status',
      user_id: current_user.id,
      username: current_user.username,
      status: status
    )
  end

  def clear_typing_status
    ChatroomChannel.broadcast_to(
      @chatroom,
      type: 'typing_status',
      user_id: current_user.id,
      username: current_user.username,
      is_typing: false
    )
  end
end
