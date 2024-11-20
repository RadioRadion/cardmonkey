# spec/controllers/user_cards_controller_spec.rb
require 'rails_helper'

RSpec.describe UserCardsController, type: :controller do
  let(:user) { create(:user) }
  let(:card_version) { create(:card_version) }
  
  before do
    sign_in user
  end

  describe 'GET #index' do
    it 'assigns user cards and renders index template' do
      user_cards = create_list(:user_card, 3, user: user)
      
      get :index, params: { user_id: user.id }
      
      expect(assigns(:user_cards)).to match_array(user_cards)
      expect(response).to render_template(:index)
    end

    it 'includes necessary associations' do
      expect(User).to receive_message_chain(:includes, :order)
      get :index, params: { user_id: user.id }
    end
  end

  describe 'GET #new' do
    it 'initializes a new form object' do
      get :new, params: { user_id: user.id }
      
      expect(assigns(:form)).to be_a(Forms::UserCardForm)
      expect(assigns(:form).user_id).to eq(user.id)
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    let(:valid_attributes) do
      {
        card_version_id: card_version.id,
        quantity: 1,
        condition: 'near_mint',
        language: 'french',
        foil: false
      }
    end

    context 'with valid parameters' do
      before do
        allow_any_instance_of(Forms::UserCardForm).to receive(:save).and_return(true)
        allow_any_instance_of(Forms::UserCardForm).to receive(:card_name).and_return('Test Card')
      end

      it 'creates a new user card and redirects' do
        post :create, params: { 
          user_id: user.id, 
          user_card: valid_attributes 
        }

        expect(response).to redirect_to(user_user_cards_path(user))
        expect(flash[:notice]).to be_present
      end
    end

    context 'with invalid parameters' do
      before do
        allow_any_instance_of(Forms::UserCardForm).to receive(:save).and_return(false)
      end

      it 'renders new template with errors' do
        post :create, params: { 
          user_id: user.id, 
          user_card: valid_attributes 
        }

        expect(response).to render_template(:new)
        expect(response.status).to eq(422)
      end
    end
  end

  describe 'GET #edit' do
    let(:user_card) { create(:user_card, user: user) }

    it 'assigns form and renders edit template' do
      get :edit, params: { user_id: user.id, id: user_card.id }

      expect(assigns(:form)).to be_a(Forms::UserCardForm)
      expect(response).to render_template(:edit)
    end
  end

  describe 'PATCH #update' do
    let(:user_card) { create(:user_card, user: user) }
    let(:valid_attributes) { { quantity: 2 } }

    context 'with valid parameters' do
      before do
        allow_any_instance_of(Forms::UserCardForm).to receive(:save).and_return(true)
      end

      it 'updates the card and redirects' do
        patch :update, params: { 
          user_id: user.id, 
          id: user_card.id, 
          user_card: valid_attributes 
        }

        expect(response).to redirect_to(user_user_cards_path(user))
        expect(flash[:notice]).to be_present
      end

      it 'returns success JSON response for AJAX request' do
        patch :update, params: { 
          user_id: user.id, 
          id: user_card.id, 
          user_card: valid_attributes 
        }, format: :json

        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)).to have_key('message')
      end
    end

    context 'with invalid parameters' do
      before do
        allow_any_instance_of(Forms::UserCardForm).to receive(:save).and_return(false)
        allow_any_instance_of(Forms::UserCardForm).to receive(:errors).and_return(
          double(full_messages: ['Error message'])
        )
      end

      it 'renders edit template with errors' do
        patch :update, params: { 
          user_id: user.id, 
          id: user_card.id, 
          user_card: valid_attributes 
        }

        expect(response).to render_template(:edit)
        expect(response.status).to eq(422)
      end

      it 'returns error JSON response for AJAX request' do
        patch :update, params: { 
          user_id: user.id, 
          id: user_card.id, 
          user_card: valid_attributes 
        }, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key('errors')
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:user_card) { create(:user_card, user: user) }

    it 'deletes the card and redirects' do
      expect {
        delete :destroy, params: { user_id: user.id, id: user_card.id }
      }.to change(UserCard, :count).by(-1)

      expect(response).to redirect_to(user_user_cards_path(user))
      expect(flash[:notice]).to be_present
    end

    it 'handles record not found' do
      delete :destroy, params: { user_id: user.id, id: 0 }

      expect(response).to redirect_to(user_user_cards_path(user))
      expect(flash[:alert]).to be_present
    end

    it 'returns appropriate JSON response' do
      delete :destroy, params: { user_id: user.id, id: user_card.id }, format: :json
      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'GET #search' do
    let(:search_results) { [{ id: 1, name: 'Black Lotus' }] }

    before do
      allow(Cards::SearchService).to receive(:call)
        .with('black lotus')
        .and_return(search_results)
    end

    it 'returns search results as JSON' do
      get :search, params: { query: 'black lotus' }

      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)).to eq(search_results)
    end
  end
end