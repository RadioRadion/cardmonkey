require 'rails_helper'

RSpec.describe MessagesController, type: :controller do
  let(:user) { create(:user) }
  let(:chatroom) { create(:chatroom, user: user) }
  let(:valid_attributes) { { content: 'Hello, world!' } }
  let(:invalid_attributes) { { content: '' } }

  describe 'POST #create' do
    context 'when user is not authenticated' do
      it 'redirects to sign in page' do
        post :create, params: { chatroom_id: chatroom.id, message: valid_attributes }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is authenticated' do
      before { sign_in user }

      context 'with valid params' do
        it 'creates a new message' do
          expect {
            post :create, params: { chatroom_id: chatroom.id, message: valid_attributes }, format: :turbo_stream
          }.to change(Message, :count).by(1)
        end

        it 'broadcasts the message' do
          expect(ChatroomChannel).to receive(:broadcast_to).with(chatroom, anything)
          post :create, params: { chatroom_id: chatroom.id, message: valid_attributes }, format: :turbo_stream
        end

        it 'creates a notification' do
          expect {
            post :create, params: { chatroom_id: chatroom.id, message: valid_attributes }, format: :turbo_stream
          }.to change(Notification, :count).by(1)
        end

        it 'responds with turbo_stream format' do
          post :create, params: { chatroom_id: chatroom.id, message: valid_attributes }, format: :turbo_stream
          expect(response.media_type).to eq Mime[:turbo_stream]
        end

        it 'redirects to chatroom path for html format' do
          post :create, params: { chatroom_id: chatroom.id, message: valid_attributes }, format: :html
          expect(response).to redirect_to(user_chatroom_path(user, chatroom))
        end
      end

      context 'with invalid params' do
        it 'does not create a new message' do
          expect {
            post :create, params: { chatroom_id: chatroom.id, message: invalid_attributes }, format: :turbo_stream
          }.not_to change(Message, :count)
        end

        it 'renders new message form for turbo_stream format' do
          post :create, params: { chatroom_id: chatroom.id, message: invalid_attributes }, format: :turbo_stream
          expect(response.media_type).to eq Mime[:turbo_stream]
        end

        it 'renders chatroom show template for html format' do
          post :create, params: { chatroom_id: chatroom.id, message: invalid_attributes }, format: :html
          expect(response).to render_template('chatrooms/show')
        end
      end
    end

    context 'when user is not authorized' do
      let(:other_user) { create(:user) }
      let(:other_chatroom) { create(:chatroom, user: other_user) }

      before { sign_in user }

      it 'returns forbidden status for turbo_stream format' do
        post :create, params: { chatroom_id: other_chatroom.id, message: valid_attributes }, format: :turbo_stream
        expect(response).to have_http_status(:forbidden)
      end

      it 'redirects to chatrooms path with alert for html format' do
        post :create, params: { chatroom_id: other_chatroom.id, message: valid_attributes }, format: :html
        expect(response).to redirect_to(user_chatrooms_path)
        expect(flash[:alert]).to be_present
      end
    end
  end
end
