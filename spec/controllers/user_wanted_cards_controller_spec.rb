require 'rails_helper'

RSpec.describe UserWantedCardsController, type: :controller do
  let(:user) { create(:user) }
  let(:card) { create(:card) }
  let(:card_version) { create(:card_version, card: card) }
  let(:valid_attributes) do
    {
      user_wanted_card: {
        card_id: card.id,
        card_version_id: card_version.id,
        min_condition: 'good',
        foil: false,
        language: 'french',
        quantity: 1
      }
    }
  end

  let(:invalid_attributes) do
    {
      user_wanted_card: {
        card_id: card.id,
        min_condition: nil,
        foil: nil,
        language: nil,
        quantity: nil
      }
    }
  end

  before do
    sign_in user
  end

  describe 'GET #index' do
    it 'returns a success response' do
      create(:user_wanted_card, user: user)
      get :index, params: { user_id: user.id }
      expect(response).to be_successful
    end

    it 'assigns all user_wanted_cards as @user_wanted_cards' do
      user_wanted_card = create(:user_wanted_card, user: user)
      get :index, params: { user_id: user.id }
      expect(assigns(:user_wanted_cards)).to include(user_wanted_card)
    end

    it 'orders cards by name_en' do
      card1 = create(:card, name_en: 'Zebra')
      card2 = create(:card, name_en: 'Antelope')
      wanted_card1 = create(:user_wanted_card, user: user, card: card1)
      wanted_card2 = create(:user_wanted_card, user: user, card: card2)
      
      get :index, params: { user_id: user.id }
      expect(assigns(:user_wanted_cards).to_a).to eq([wanted_card2, wanted_card1])
    end
  end

  describe 'GET #new' do
    it 'returns a success response' do
      get :new, params: { user_id: user.id }
      expect(response).to be_successful
    end

    it 'initializes a new form object' do
      get :new, params: { user_id: user.id }
      expect(assigns(:form)).to be_a(Forms::UserWantedCardForm)
      expect(assigns(:form).user_id).to eq(user.id)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new UserWantedCard' do
        expect {
          post :create, params: valid_attributes.merge(user_id: user.id)
        }.to change(UserWantedCard, :count).by(1)
      end

      it 'redirects to the user_wanted_cards list' do
        post :create, params: valid_attributes.merge(user_id: user.id)
        expect(response).to redirect_to(user_user_wanted_cards_path(user))
      end

      it 'sets a success notice' do
        post :create, params: valid_attributes.merge(user_id: user.id)
        expect(flash[:notice]).to be_present
      end
    end

    context 'with invalid params' do
      it 'does not create a new UserWantedCard' do
        expect {
          post :create, params: invalid_attributes.merge(user_id: user.id)
        }.not_to change(UserWantedCard, :count)
      end

      it 'returns unprocessable_entity status' do
        post :create, params: invalid_attributes.merge(user_id: user.id)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET #edit' do
    let(:user_wanted_card) { create(:user_wanted_card, user: user) }

    it 'returns a success response' do
      get :edit, params: { id: user_wanted_card.id, user_id: user.id }
      expect(response).to be_successful
    end

    it 'assigns the requested user_wanted_card' do
      get :edit, params: { id: user_wanted_card.id, user_id: user.id }
      expect(assigns(:user_wanted_card)).to eq(user_wanted_card)
    end

    it 'loads card versions for the select' do
      get :edit, params: { id: user_wanted_card.id, user_id: user.id }
      expect(assigns(:versions)).to be_present
    end

    it 'initializes the form with the user_wanted_card data' do
      get :edit, params: { id: user_wanted_card.id, user_id: user.id }
      expect(assigns(:form)).to be_a(Forms::UserWantedCardForm)
    end
  end

  describe 'PATCH #update' do
    let(:user_wanted_card) { create(:user_wanted_card, user: user) }
    let(:new_attributes) do
      {
        user_wanted_card: {
          min_condition: 'mint',
          quantity: 2
        }
      }
    end

    context 'with valid params' do
      context 'HTML format' do
        it 'updates the requested user_wanted_card' do
          patch :update, params: new_attributes.merge(id: user_wanted_card.id, user_id: user.id)
          user_wanted_card.reload
          expect(user_wanted_card.min_condition).to eq('mint')
          expect(user_wanted_card.quantity).to eq(2)
        end

        it 'redirects to the user_wanted_cards list' do
          patch :update, params: new_attributes.merge(id: user_wanted_card.id, user_id: user.id)
          expect(response).to redirect_to(user_user_wanted_cards_path(user))
        end
      end

      context 'JSON format' do
        it 'returns a JSON success response' do
          patch :update, params: new_attributes.merge(id: user_wanted_card.id, user_id: user.id), format: :json
          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)).to have_key('message')
        end
      end
    end

    context 'with invalid params' do
      context 'HTML format' do
        it 'returns unprocessable_entity status' do
          patch :update, params: invalid_attributes.merge(id: user_wanted_card.id, user_id: user.id)
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'JSON format' do
        it 'returns a JSON error response' do
          patch :update, params: invalid_attributes.merge(id: user_wanted_card.id, user_id: user.id), format: :json
          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)).to have_key('errors')
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:user_wanted_card) { create(:user_wanted_card, user: user) }

    context 'HTML format' do
      it 'destroys the requested user_wanted_card' do
        expect {
          delete :destroy, params: { id: user_wanted_card.id, user_id: user.id }
        }.to change(UserWantedCard, :count).by(-1)
      end

      it 'redirects to the user_wanted_cards list' do
        delete :destroy, params: { id: user_wanted_card.id, user_id: user.id }
        expect(response).to redirect_to(user_user_wanted_cards_path(user))
      end

      it 'sets a success notice with the card name' do
        delete :destroy, params: { id: user_wanted_card.id, user_id: user.id }
        expect(flash[:notice]).to be_present
      end

      context 'when record is not found' do
        it 'redirects to index with an alert' do
          delete :destroy, params: { id: 999999, user_id: user.id }
          expect(response).to redirect_to(user_user_wanted_cards_path(user))
          expect(flash[:alert]).to be_present
        end
      end
    end

    context 'JSON format' do
      it 'returns no content on success' do
        delete :destroy, params: { id: user_wanted_card.id, user_id: user.id }, format: :json
        expect(response).to have_http_status(:no_content)
      end

      it 'returns not found when record does not exist' do
        delete :destroy, params: { id: 999999, user_id: user.id }, format: :json
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
