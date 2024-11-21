class Message < ApplicationRecord
  belongs_to :user
  belongs_to :chatroom
  
  validates :content, presence: true, allow_blank: false
  
  after_create :create_notification
  
  scope :unread, -> { where(read_at: nil) }
  
  def timestamp
    created_at.strftime("%H:%M %d-%m-%Y")
  end

  def trade_message?
    content.match?(/trade_id:\d+/)
  end

  def trade_id
    return unless trade_message?
    content.match(/trade_id:(\d+)/)[1]
  end

  def display_content
    if trade_message?
      "Nouveau trade proposé !"
    else
      content
    end
  end
  
  private
  
  def create_notification
    return unless chatroom
    
    recipient_id = if user_id == chatroom.user_id
                    chatroom.user_id_invit
                  else
                    chatroom.user_id
                  end
    
    notification_content = trade_message? ? "Nouveau trade proposé !" : content
    
    Notification.create_notification(
      recipient_id,
      notification_content
    )
  end
end
