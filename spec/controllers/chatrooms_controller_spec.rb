require 'rails_helper'

RSpec.describe ChatroomsController, type: :controller do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  before do
    sign_in user
  end

  describe 'before actions' do
    it 'requires authentication' do
      sign_out user
      get :index, params: { user_id: user.id }
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe 'GET #index' do
    let!(:chatroom1) { create(:chatroom, user: user, user_invit: other_user) }
    let!(:chatroom2) { create(:chatroom, user: create(:user), user_invit: create(:user)) }
    let!(:message) { create(:message, chatroom: chatroom1, user: other_user) }

    context 'when accessing own chatrooms' do
      before { get :index, params: { user_id: user.id } }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'assigns @chatrooms with user chatrooms ordered by last message' do
        expect(assigns(:chatrooms)).to include(chatroom1)
        expect(assigns(:chatrooms)).not_to include(chatroom2)
      end

      it 'includes necessary associations' do
        expect(assigns(:chatrooms).first.association(:messages).loaded?).to be true
        expect(assigns(:chatrooms).first.association(:user).loaded?).to be true
        expect(assigns(:chatrooms).first.association(:user_invit).loaded?).to be true
      end
    end

    context 'when trying to access another user\'s chatrooms' do
      it 'redirects to own chatrooms' do
        get :index, params: { user_id: other_user.id }
        expect(response).to redirect_to(user_chatrooms_path(user))
        expect(flash[:alert]).to eq("Vous ne pouvez pas accéder aux messages d'autres utilisateurs.")
      end
    end
  end

  describe 'GET #show' do
    let(:chatroom) { create(:chatroom, user: user, user_invit: other_user) }
    let!(:message) { create(:message, chatroom: chatroom, user: other_user, read_at: nil) }

    context 'when accessing own chatroom' do
      before { get :show, params: { user_id: user.id, id: chatroom.id } }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'assigns @chatroom' do
        expect(assigns(:chatroom)).to eq(chatroom)
      end

      it 'assigns @messages ordered by creation time' do
        expect(assigns(:messages)).to eq([message])
      end

      it 'assigns @other_user' do
        expect(assigns(:other_user)).to eq(other_user)
      end

      it 'marks unread messages as read' do
        expect(message.reload.read_at).not_to be_nil
      end

      it 'assigns @chatrooms for sidebar' do
        expect(assigns(:chatrooms)).to include(chatroom)
      end
    end

    context 'when trying to access another user\'s chatroom' do
      it 'redirects to own chatrooms' do
        get :show, params: { user_id: other_user.id, id: chatroom.id }
        expect(response).to redirect_to(user_chatrooms_path(user))
        expect(flash[:alert]).to eq("Vous ne pouvez pas accéder aux messages d'autres utilisateurs.")
      end
    end

    context 'when trying to access unauthorized chatroom' do
      let(:unauthorized_chatroom) { create(:chatroom, user: create(:user), user_invit: create(:user)) }

      it 'redirects to own chatrooms' do
        get :show, params: { user_id: user.id, id: unauthorized_chatroom.id }
        expect(response).to redirect_to(user_chatrooms_path(user))
        expect(flash[:alert]).to eq("Vous n'avez pas accès à cette conversation.")
      end
    end
  end

  describe 'POST #create' do
    let(:valid_params) { { user_id: user.id, chatroom: { user_id_invit: other_user.id } } }

    context 'with valid params' do
      it 'creates a new Chatroom' do
        expect {
          post :create, params: valid_params
        }.to change(Chatroom, :count).by(1)
      end

      it 'assigns current user as chatroom user' do
        post :create, params: valid_params
        expect(Chatroom.last.user).to eq(user)
      end

      it 'redirects to the created chatroom' do
        post :create, params: valid_params
        expect(response).to redirect_to(user_chatroom_path(user, Chatroom.last))
        expect(flash[:notice]).to eq('Conversation créée avec succès.')
      end
    end

    context 'with invalid params' do
      let(:invalid_params) { { user_id: user.id, chatroom: { user_id_invit: user.id } } }

      it 'does not create a new Chatroom' do
        expect {
          post :create, params: invalid_params
        }.not_to change(Chatroom, :count)
      end

      it 'redirects to chatrooms index with error message' do
        post :create, params: invalid_params
        expect(response).to redirect_to(user_chatrooms_path(user))
        expect(flash[:alert]).to eq('Impossible de créer la conversation.')
      end
    end

    context 'when chatroom already exists' do
      before { create(:chatroom, user: user, user_invit: other_user) }

      it 'does not create a new chatroom' do
        expect {
          post :create, params: valid_params
        }.not_to change(Chatroom, :count)
      end

      it 'redirects to chatrooms index with error message' do
        post :create, params: valid_params
        expect(response).to redirect_to(user_chatrooms_path(user))
        expect(flash[:alert]).to eq('Impossible de créer la conversation.')
      end
    end
  end
end
