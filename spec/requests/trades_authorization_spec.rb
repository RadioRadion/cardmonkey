require 'rails_helper'

# Covers the IDOR fix (AUDIT_MVP A1): trade actions are scoped to participants.
RSpec.describe 'Trades authorization', type: :request do
  let(:alice) { create(:user) }
  let(:bob)   { create(:user) }
  let(:carol) { create(:user) }
  let(:trade) { create(:trade, user: alice, user_invit: bob) }

  context 'as a non-participant' do
    before { sign_in carol }

    it 'cannot view a trade it is not part of' do
      get trade_path(trade)
      expect(response).to redirect_to(root_path)
    end

    it 'cannot edit a trade it is not part of' do
      get edit_trade_path(trade)
      expect(response).to redirect_to(root_path)
    end
  end

  context 'as a participant' do
    before { sign_in alice }

    it 'can view its own trade' do
      get trade_path(trade)
      expect(response).to have_http_status(:ok)
    end
  end
end
