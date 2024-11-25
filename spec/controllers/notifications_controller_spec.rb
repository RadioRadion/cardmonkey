require 'rails_helper'

RSpec.describe NotificationsController, type: :controller do
  let(:user) { create(:user) }
  let!(:notification) { create(:notification, user: user) }

  before do
    sign_in user
  end

  describe 'GET #index' do
    it 'returns a successful response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns @notifications' do
      get :index
      expect(assigns(:notifications)).to include(notification)
    end

    context 'with type filter' do
      let!(:trade_notification) { create(:notification, :trade_notification, user: user) }
      let!(:message_notification) { create(:notification, :message_notification, user: user) }

      it 'filters notifications by type' do
        get :index, params: { type: 'trade' }
        expect(assigns(:notifications)).to include(trade_notification)
        expect(assigns(:notifications)).not_to include(message_notification)
      end
    end
  end

  describe 'PATCH #mark_as_read' do
    let!(:unread_notification) { create(:notification, :unread, user: user) }

    it 'marks the notification as read' do
      patch :mark_as_read, params: { id: unread_notification.id }
      expect(unread_notification.reload.status).to eq('read')
    end

    it 'sets the read_at timestamp' do
      patch :mark_as_read, params: { id: unread_notification.id }
      expect(unread_notification.reload.read_at).not_to be_nil
    end

    it 'returns success status' do
      patch :mark_as_read, params: { id: unread_notification.id }
      expect(response).to be_successful
    end

    context 'when notification does not belong to user' do
      let(:other_user_notification) { create(:notification) }

      it 'returns unauthorized status' do
        patch :mark_as_read, params: { id: other_user_notification.id }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH #mark_all_as_read' do
    before do
      create_list(:notification, 3, :unread, user: user)
    end

    it 'marks all notifications as read' do
      patch :mark_all_as_read
      expect(user.notifications.unread.count).to eq(0)
    end

    it 'sets read_at timestamp for all notifications' do
      patch :mark_all_as_read
      user.notifications.each do |notification|
        expect(notification.read_at).not_to be_nil
      end
    end

    it 'returns success status' do
      patch :mark_all_as_read
      expect(response).to be_successful
    end

    it 'only marks current user notifications as read' do
      other_user_notification = create(:notification, :unread)
      patch :mark_all_as_read
      expect(other_user_notification.reload.status).to eq('unread')
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the notification' do
      expect {
        delete :destroy, params: { id: notification.id }
      }.to change(Notification, :count).by(-1)
    end

    it 'returns success status' do
      delete :destroy, params: { id: notification.id }
      expect(response).to be_successful
    end

    context 'when notification does not belong to user' do
      let(:other_user_notification) { create(:notification) }

      it 'returns unauthorized status' do
        delete :destroy, params: { id: other_user_notification.id }
        expect(response).to have_http_status(:unauthorized)
      end

      it 'does not delete the notification' do
        expect {
          delete :destroy, params: { id: other_user_notification.id }
        }.not_to change(Notification, :count)
      end
    end
  end

  describe 'DELETE #clear_all' do
    before do
      create_list(:notification, 3, user: user)
    end

    it 'deletes all notifications for the current user' do
      expect {
        delete :clear_all
      }.to change { user.notifications.count }.to(0)
    end

    it 'returns success status' do
      delete :clear_all
      expect(response).to be_successful
    end

    it 'only deletes current user notifications' do
      other_user_notification = create(:notification)
      expect {
        delete :clear_all
      }.not_to change { Notification.where.not(user: user).count }
    end
  end
end
