require 'rails_helper'

RSpec.describe Trade, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:user_invit).class_name('User') }
    it { should have_many(:trade_user_cards).dependent(:destroy) }
    it { should have_many(:user_cards).through(:trade_user_cards) }
  end

  describe 'status' do
    # status is enum-backed with a default applied before validation; it is
    # therefore always present rather than validatable as "blank".
    it 'defaults to pending on a new record' do
      trade = Trade.new
      trade.valid?
      expect(trade.status).to eq('pending')
    end

    it 'rejects participants being the same user' do
      user = create(:user)
      trade = build(:trade, user: user, user_invit: user)
      expect(trade).not_to be_valid
    end
  end

  describe 'scopes' do
    let!(:pending_trade) { create(:trade, :pending) }
    let!(:accepted_trade) { create(:trade, :accepted) }
    let!(:done_trade) { create(:trade, :done) }

    describe '.pending' do
      it 'returns only pending trades' do
        expect(Trade.pending).to include(pending_trade)
        expect(Trade.pending).not_to include(accepted_trade, done_trade)
      end
    end

    describe '.accepted' do
      it 'returns only accepted trades' do
        expect(Trade.accepted).to include(accepted_trade)
        expect(Trade.accepted).not_to include(pending_trade, done_trade)
      end
    end

    describe '.done' do
      it 'returns only done trades' do
        expect(Trade.done).to include(done_trade)
        expect(Trade.done).not_to include(pending_trade, accepted_trade)
      end
    end

    describe '.active' do
      it 'returns in-progress trades (pending, modified, accepted), not done/cancelled' do
        modified_trade = create(:trade, :modified)
        cancelled_trade = create(:trade, status: :cancelled)
        expect(Trade.active).to include(pending_trade, accepted_trade, modified_trade)
        expect(Trade.active).not_to include(done_trade, cancelled_trade)
      end
    end
  end

  describe 'instance methods' do
    let(:trade) { create(:trade) }
    let(:current_user) { create(:user) }
    let(:partner) { create(:user) }

    before do
      trade.user = current_user
      trade.user_invit = partner
    end

    # Note: status badge rendering is a view concern (TradesHelper#trade_status_badge),
    # not a model method — tested at the view/helper level.

    describe '#partner_for and #other_user' do
      it 'returns the correct partner for the current user' do
        expect(trade.partner_for(current_user)).to eq(partner)
        expect(trade.partner_for(partner)).to eq(current_user)
      end

      it 'returns the same result for other_user as partner_for' do
        expect(trade.other_user(current_user)).to eq(trade.partner_for(current_user))
        expect(trade.other_user(partner)).to eq(trade.partner_for(partner))
      end
    end

    describe '#partner_name_for' do
      it 'returns the partner username when partner exists' do
        expect(trade.partner_name_for(current_user)).to eq(partner.username)
      end

      it 'returns "Utilisateur supprimé" when partner is nil' do
        trade.user_invit = nil
        expect(trade.partner_name_for(current_user)).to eq('Utilisateur supprimé')
      end
    end

    # Note: notifying partners on status change is a controller concern
    # (TradesController#notify_trade_status_change), not a model method.
  end

  describe 'class methods' do
    describe '.save_message' do
      let(:user1) { create(:user) }
      let(:user2) { create(:user) }

      it 'creates a chatroom if it does not exist' do
        expect {
          Trade.save_message(user1.id, user2.id, "Test message")
        }.to change(Chatroom, :count).by(1)
      end

      it 'creates a message in existing chatroom' do
        chatroom = create(:chatroom, user: user1, user_id_invit: user2.id)
        expect {
          Trade.save_message(user1.id, user2.id, "Test message")
        }.to change(Message, :count).by(1)
      end

      it 'uses existing chatroom if it exists' do
        chatroom = create(:chatroom, user: user1, user_id_invit: user2.id)
        expect {
          Trade.save_message(user1.id, user2.id, "Test message")
        }.not_to change(Chatroom, :count)
      end
    end
  end
end
