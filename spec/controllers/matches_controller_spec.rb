require 'rails_helper'

RSpec.describe MatchesController, type: :controller do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:user_card) { create(:user_card, user: other_user) }
  let(:user_wanted_card) { create(:user_wanted_card, user: user) }
  let!(:match) { create(:match, user: user, user_card: user_card, user_wanted_card: user_wanted_card, user_id_target: other_user.id) }

  before do
    sign_in user
  end

  describe 'GET #index' do
    before { get :index }

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @matches_by_user' do
      expect(assigns(:matches_by_user)).to be_a(Hash)
      expect(assigns(:matches_by_user).keys).to include(other_user)
    end

    it 'assigns statistics variables' do
      expect(assigns(:matches_count)).to eq(1)
      expect(assigns(:matched_users_count)).to eq(1)
      expect(assigns(:active_trades_count)).to eq(0)
    end
  end

  describe 'GET #show' do
    before { get :show, params: { id: match.id }, format: :json }

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'returns match details in JSON format' do
      json_response = JSON.parse(response.body)
      expect(json_response).to include('match', 'user_card', 'user_wanted_card')
      expect(json_response['match']['id']).to eq(match.id)
    end
  end

  describe 'GET #matches' do
    before { get :matches }

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'assigns statistics variables' do
      expect(assigns(:stats)).to include(
        :total_matches,
        :matches_by_condition,
        :matches_by_language,
        :top_matched_users,
        :recent_matches,
        :pending_trades,
        :completed_trades
      )
    end

    it 'includes correct match count' do
      expect(assigns(:stats)[:total_matches]).to eq(1)
    end

    it 'includes recent matches' do
      expect(assigns(:stats)[:recent_matches]).to include(match)
    end
  end
end
