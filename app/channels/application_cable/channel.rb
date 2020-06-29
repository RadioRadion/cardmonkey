module ApplicationCable
  class Channel < ActionCable::Channel::Base
    def subscribed
      stream_from "chatroom_#{params[:chatroom_id]}"
    end
  end
end
