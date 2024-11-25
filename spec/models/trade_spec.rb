require 'rails_helper'

RSpec.describe Trade, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:user_invit).class_name('User').optional }
    it { should have_many(:trade_user_cards).dependent(:destroy) }
    it { should have_many(:user_cards).through(:trade_user_cards) }
  end

  describe 'validations' do
    it { should validate_presence_of(:status) }
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
      it 'returns trades that are pending or accepted with accepted_at not nil' do
        active_pending = create(:trade, :pending, accepted_at: Time.current)
        expect(Trade.active).to include(accepted_trade, active_pending)
        expect(Trade.active).not_to include(pending_trade, done_trade)
      end
    end
  end

  describe 'instance methods' do
    let(:trade) { create(:trade, :with_cards) }
    let(:current_user) { trade.user }
    let(:partner) { trade.user_invit }

    describe '#status_badge' do
      it 'returns the correct HTML for pending status' do
        expect(trade.status_badge).to include('En attente')
        expect(trade.status_badge).to include('bg-yellow-100')
      end

      it 'returns the correct HTML for accepted status' do
        trade.update(status: :accepted)
        expect(trade.status_badge).to include('Accepté')
        expect(trade.status_badge).to include('bg-green-100')
      end

      it 'returns the correct HTML for rejected status' do
        trade.update(status: :rejected)
        expect(trade.status_badge).to include('Refusé')
        expect(trade.status_badge).to include('bg-red-100')
      end

      it 'returns the correct HTML for completed status' do
        trade.update(status: :completed)
        expect(trade.status_badge).to include('Complété')
        expect(trade.status_badge).to include('bg-blue-100')
      end
    end

    describe '#partner_for' do
      it 'returns the correct partner for the current user' do
        expect(trade.partner_for(current_user)).to eq(partner)
        expect(trade.partner_for(partner)).to eq(current_user)
      end
    end

    describe '#partner_name_for' do
      it 'returns the partner username when partner exists' do
        expect(trade.partner_name_for(current_user)).to eq(partner.username)
      end

      it 'returns "Utilisateur supprimé" when partner is nil' do
        trade.update(user_invit: nil)
        expect(trade.partner_name_for(current_user)).to eq('Utilisateur supprimé')
      end
    end

    describe '#notify_status_change' do
      it 'creates a notification and saves a message' do
        expect(Notification).to receive(:create_notification)
        expect(Trade).to receive(:save_message)
        trade.notify_status_change(current_user.id, "Test message")
      end
    end
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
