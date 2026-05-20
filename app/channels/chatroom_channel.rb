class ChatroomChannel < ApplicationCable::Channel
  def subscribed
    @chatroom = Chatroom.find(params[:id])
    if authorized?
      stream_for @chatroom
      broadcast_user_status('online')
      mark_messages_as_read
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

  def read(data)
    return unless authorized?
    
    message = @chatroom.messages.find(data['message_id'])
    return if message.user == current_user
    
    message.mark_as_read!(current_user)
    broadcast_read_status(message)
  end

  def mark_delivered(data)
    return unless authorized?
    
    message = @chatroom.messages.find(data['message_id'])
    return if message.user == current_user
    
    message.mark_as_delivered!
    broadcast_delivery_status(message) if message.saved_change_to_delivered_at?
  end

  private

  def authorized?
    @chatroom.participant?(current_user)
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

  def broadcast_read_status(message)
    ChatroomChannel.broadcast_to(
      @chatroom,
      type: 'read_status',
      message_id: message.id,
      reader_id: current_user.id,
      read_at: message.read_at
    )
  end

  def broadcast_delivery_status(message)
    ChatroomChannel.broadcast_to(
      @chatroom,
      type: 'delivery_status',
      message_id: message.id,
      delivered: true,
      delivered_at: message.delivered_at
    )
  end

  def mark_messages_as_read
    @chatroom.messages
            .where.not(user: current_user)
            .where(read_at: nil)
            .find_each do |message|
      message.mark_as_read!(current_user)
      broadcast_read_status(message)
    end
  end
end
