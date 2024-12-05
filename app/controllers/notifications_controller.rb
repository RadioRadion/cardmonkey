class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.recent
    @unread_count = current_user.notifications.unread.count
  end

  def mark_as_read
    notification = current_user.notifications.find(params[:id])
    notification.mark_as_read!
    
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back(fallback_location: root_path) }
    end
  end

  def mark_all_as_read
    current_user.notifications.mark_all_as_read(current_user.id)
    
    respond_to do |format|
      format.turbo_stream { 
        render turbo_stream: [
          turbo_stream.update('notifications_count', ''),
          turbo_stream.update('notifications_list', 
            partial: 'notifications/notifications',
            locals: { notifications: current_user.notifications.recent }
          )
        ]
      }
      format.html { redirect_back(fallback_location: root_path) }
    end
  end
end
