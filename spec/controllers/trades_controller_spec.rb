require 'rails_helper'

RSpec.describe TradesController, type: :controller do
  let(:user) { create(:user) }
  let(:partner) { create(:user) }
  let(:trade) { create(:trade, :with_cards, user: user, user_invit: partner) }

  before do
    sign_in user
  end

  describe 'GET #index' do
    before do
      create(:trade, :pending, user: user)
      create(:trade, :accepted, user: user)
      create(:trade, :done, user: user)
      create(:match, user_card: create(:user_card, user: partner), user_wanted_card: create(:user_wanted_card, user: user))
      get :index
    end

    it 'assigns @trades grouped by status' do
      expect(assigns(:trades)).to be_a(Hash)
      expect(assigns(:trades)).to have_key("0") # pending
      expect(assigns(:trades)).to have_key("1") # accepted
      expect(assigns(:trades)).to have_key("2") # done
    end

    it 'assigns @matches' do
      expect(assigns(:matches)).not_to be_nil
      expect(assigns(:matches)).to be_a(ActiveRecord::Relation)
    end

    it 'assigns @stats' do
      expect(assigns(:stats)).to include(
        trades_completed: be_a(Integer),
        cards_available: be_a(Integer),
        cards_wanted: be_a(Integer),
        potential_matches: be_a(Integer)
      )
    end

    it 'renders the index template' do
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show' do
    before do
      get :show, params: { id: trade.id }
    end

    it 'assigns @trade' do
      expect(assigns(:trade)).to eq(trade)
    end

    it 'assigns @cards_by_user' do
      expect(assigns(:cards_by_user)).to be_a(Hash)
      expect(assigns(:cards_by_user)).to have_key(user.id)
      expect(assigns(:cards_by_user)).to have_key(partner.id)
    end

    it 'renders the show template' do
      expect(response).to render_template(:show)
    end
  end

  describe 'GET #edit' do
    before do
      get :edit, params: { id: trade.id }
    end

    it 'assigns @trade' do
      expect(assigns(:trade)).to eq(trade)
    end

    it 'assigns @trade_data' do
      expect(assigns(:trade_data)).not_to be_nil
    end

    it 'renders the edit template' do
      expect(response).to render_template(:edit)
    end
  end

  describe 'POST #create' do
    let(:valid_params) do
      {
        trade: {
          user_id_invit: partner.id,
          offer: create(:user_card, user: user).id.to_s,
          target: create(:user_card, user: partner).id.to_s
        }
      }
    end

    context 'with valid params' do
      it 'creates a new trade' do
        expect {
          post :create, params: valid_params
        }.to change(Trade, :count).by(1)
      end

      it 'creates trade_user_cards' do
        expect {
          post :create, params: valid_params
        }.to change(TradeUserCard, :count).by(2)
      end

      it 'creates a notification' do
        expect {
          post :create, params: valid_params
        }.to change(Notification, :count).by(1)
      end

      it 'redirects to user path' do
        post :create, params: valid_params
        expect(response).to redirect_to(user_path(user))
      end
    end

    context 'with invalid params' do
      it 'redirects back with error' do
        post :create, params: { trade: { user_id_invit: nil } }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'PATCH #update' do
    context 'when accepting trade' do
      it 'updates trade status to accepted' do
        patch :update, params: { id: trade.id, status: 'accepted' }
        expect(trade.reload.status).to eq('accepted')
      end

      it 'creates notification and message' do
        expect {
          patch :update, params: { id: trade.id, status: 'accepted' }
        }.to change(Notification, :count).by(1)
      end
    end

    context 'when completing trade' do
      let(:accepted_trade) { create(:trade, :accepted, user: user, user_invit: partner) }

      it 'updates trade status to done' do
        patch :update, params: { id: accepted_trade.id, status: 'done' }
        expect(accepted_trade.reload.status).to eq('done')
      end
    end

    context 'when modifying trade' do
      let(:new_card) { create(:user_card, user: user) }

      it 'updates trade cards' do
        patch :update, params: {
          id: trade.id,
          trade: {
            offer: new_card.id.to_s
          }
        }
        expect(trade.reload.trade_user_cards.pluck(:user_card_id)).to include(new_card.id)
      end
    end
  end

  describe 'GET #new_proposition' do
    before do
      create(:user_wanted_card, user: partner, card: create(:card))
      create(:user_wanted_card, user: user, card: create(:card))
      get :new_proposition, params: { partner_id: partner.id }
    end

    it 'assigns @user_cards' do
      expect(assigns(:user_cards)).not_to be_nil
    end

    it 'assigns @partner_cards' do
      expect(assigns(:partner_cards)).not_to be_nil
    end

    it 'assigns @trade_history' do
      expect(assigns(:trade_history)).not_to be_nil
    end

    it 'assigns @suggested_cards' do
      expect(assigns(:suggested_cards)).to be_a(Hash)
      expect(assigns(:suggested_cards)).to have_key(:for_partner)
      expect(assigns(:suggested_cards)).to have_key(:for_me)
    end

    it 'renders the new_proposition template' do
      expect(response).to render_template(:new_proposition)
    end
  end

  describe 'GET #search_cards' do
    context 'when searching user cards' do
      before do
        get :search_cards, params: { partner_id: partner.id, side: 'user', query: 'test' }
      end

      it 'returns filtered cards' do
        expect(assigns(:filtered_cards)).not_to be_nil
      end

      it 'renders the card partial' do
        expect(response).to render_template(partial: '_card')
      end
    end

    context 'when searching partner cards' do
      before do
        get :search_cards, params: { partner_id: partner.id, side: 'partner', query: 'test' }
      end

      it 'returns filtered cards' do
        expect(assigns(:filtered_cards)).not_to be_nil
      end

      it 'renders the card partial' do
        expect(response).to render_template(partial: '_card')
      end
    end
  end

  describe 'POST #update_trade_value' do
    let(:user_card) { create(:user_card, user: user) }
    let(:partner_card) { create(:user_card, user: partner) }

    before do
      post :update_trade_value, params: {
        partner_id: partner.id,
        user_cards: { user_card.id => 1 },
        partner_cards: { partner_card.id => 1 }
      }, format: :turbo_stream
    end

    it 'assigns @selected_cards' do
      expect(assigns(:selected_cards)).to be_a(Hash)
      expect(assigns(:selected_cards)).to have_key(:user)
      expect(assigns(:selected_cards)).to have_key(:partner)
    end

    it 'assigns @values' do
      expect(assigns(:values)).to be_a(Hash)
      expect(assigns(:values)).to have_key(:user_total)
      expect(assigns(:values)).to have_key(:partner_total)
    end

    it 'assigns @trade_balance' do
      expect(assigns(:trade_balance)).not_to be_nil
    end

    it 'renders turbo_stream format' do
      expect(response.media_type).to eq Mime[:turbo_stream]
    end
  end
end
