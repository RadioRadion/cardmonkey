require 'rails_helper'

RSpec.describe UserCardsController, type: :controller do
  let(:user) { create(:user) }
  let(:card_version) { create(:card_version) }
  let(:user_card) { create(:user_card, user: user, card_version: card_version) }

  before do
    sign_in user
  end

  describe 'GET #index' do
    before do
      create_list(:user_card, 3, user: user)
      get :index, params: { user_id: user.id }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @user_cards' do
      expect(assigns(:user_cards)).to eq(user.user_cards.includes(card_version: [:card, :extension]).order('cards.name_en'))
    end

    it 'renders the index template' do
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #new' do
    before do
      get :new, params: { user_id: user.id }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'initializes a new UserCardForm' do
      expect(assigns(:form)).to be_a(Forms::UserCardForm)
    end

    it 'renders the new template' do
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    let(:valid_attributes) do
      {
        user_id: user.id,
        user_card: {
          card_version_id: card_version.id,
          quantity: 1,
          condition: 'good',
          language: 'en',
          foil: false
        }
      }
    end

    context 'with valid params' do
      it 'creates a new UserCard' do
        expect {
          post :create, params: valid_attributes
        }.to change(UserCard, :count).by(1)
      end

      it 'redirects to the user_cards index' do
        post :create, params: valid_attributes
        expect(response).to redirect_to(user_user_cards_path(user))
      end

      it 'sets a success notice' do
        post :create, params: valid_attributes
        expect(flash[:notice]).to be_present
      end
    end

    context 'with invalid params' do
      let(:invalid_attributes) do
        {
          user_id: user.id,
          user_card: {
            card_version_id: nil,
            quantity: nil,
            condition: nil,
            language: nil
          }
        }
      end

      it 'does not create a new UserCard' do
        expect {
          post :create, params: invalid_attributes
        }.not_to change(UserCard, :count)
      end

      it 'renders the new template' do
        post :create, params: invalid_attributes
        expect(response).to render_template(:new)
      end

      it 'returns unprocessable_entity status' do
        post :create, params: invalid_attributes
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET #edit' do
    before do
      get :edit, params: { user_id: user.id, id: user_card.id }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'assigns the requested user_card' do
      expect(assigns(:user_card)).to eq(user_card)
    end

    it 'initializes a UserCardForm with the user_card data' do
      expect(assigns(:form)).to be_a(Forms::UserCardForm)
    end

    it 'renders the edit template' do
      expect(response).to render_template(:edit)
    end
  end

  describe 'PATCH #update' do
    let(:new_attributes) do
      {
        user_id: user.id,
        id: user_card.id,
        user_card: {
          quantity: 2,
          condition: 'mint',
          language: 'fr'
        }
      }
    end

    context 'with valid params' do
      context 'HTML format' do
        it 'updates the requested user_card' do
          patch :update, params: new_attributes
          user_card.reload
          expect(user_card.quantity).to eq(2)
          expect(user_card.condition).to eq('mint')
          expect(user_card.language).to eq('fr')
        end

        it 'redirects to the user_cards index' do
          patch :update, params: new_attributes
          expect(response).to redirect_to(user_user_cards_path(user))
        end
      end

      context 'JSON format' do
        before do
          patch :update, params: new_attributes, format: :json
        end

        it 'returns success json response' do
          expect(response).to have_http_status(:success)
          expect(JSON.parse(response.body)).to include('message', 'quantity')
        end
      end
    end

    context 'with invalid params' do
      let(:invalid_attributes) do
        {
          user_id: user.id,
          id: user_card.id,
          user_card: {
            quantity: nil,
            condition: nil
          }
        }
      end

      context 'HTML format' do
        it 'renders the edit template' do
          patch :update, params: invalid_attributes
          expect(response).to render_template(:edit)
        end

        it 'returns unprocessable_entity status' do
          patch :update, params: invalid_attributes
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'JSON format' do
        it 'returns error json response' do
          patch :update, params: invalid_attributes, format: :json
          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)).to include('message', 'errors')
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:user_card_to_delete) { create(:user_card, user: user) }

    context 'HTML format' do
      it 'destroys the requested user_card' do
        expect {
          delete :destroy, params: { user_id: user.id, id: user_card_to_delete.id }
        }.to change(UserCard, :count).by(-1)
      end

      it 'redirects to the user_cards list' do
        delete :destroy, params: { user_id: user.id, id: user_card_to_delete.id }
        expect(response).to redirect_to(user_user_cards_path(user))
      end
    end

    context 'JSON format' do
      it 'returns no content status' do
        delete :destroy, params: { user_id: user.id, id: user_card_to_delete.id }, format: :json
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when record not found' do
      context 'HTML format' do
        it 'redirects to index with alert' do
          delete :destroy, params: { user_id: user.id, id: 0 }
          expect(response).to redirect_to(user_user_cards_path(user))
          expect(flash[:alert]).to be_present
        end
      end

      context 'JSON format' do
        it 'returns not found status with error message' do
          delete :destroy, params: { user_id: user.id, id: 0 }, format: :json
          expect(response).to have_http_status(:not_found)
          expect(JSON.parse(response.body)).to include('error')
        end
      end
    end
  end

  describe 'GET #search' do
    let(:query) { 'Black Lotus' }

    before do
      allow(Cards::SearchService).to receive(:call).with(query).and_return([])
      get :search, params: { query: query }
    end

    it 'calls the search service' do
      expect(Cards::SearchService).to have_received(:call).with(query)
    end

    it 'returns json response' do
      expect(response.content_type).to include('application/json')
    end
  end
end
