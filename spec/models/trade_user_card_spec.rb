require 'rails_helper'

RSpec.describe TradeUserCard, type: :model do
  describe 'associations' do
    it { should belong_to(:trade) }
    it { should belong_to(:user_card) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      trade_user_card = build(:trade_user_card)
      expect(trade_user_card).to be_valid
    end

    context 'with traits' do
      it 'creates trade_user_card with complete trade' do
        trade_user_card = create(:trade_user_card, :with_complete_trade)
        expect(trade_user_card.trade.trade_user_cards).to be_present
      end

      it 'creates trade_user_card with accepted trade' do
        trade_user_card = create(:trade_user_card, :with_accepted_trade)
        expect(trade_user_card.trade).to be_accepted
      end

      it 'creates trade_user_card with done trade' do
        trade_user_card = create(:trade_user_card, :with_done_trade)
        expect(trade_user_card.trade).to be_done
      end
    end
  end

  describe 'nested associations' do
    let(:trade_user_card) { create(:trade_user_card) }

    it 'accesses card through user_card' do
      expect(trade_user_card.user_card.card_version.card).to be_present
    end

    it 'accesses user through user_card' do
      expect(trade_user_card.user_card.user).to be_present
    end
  end

  describe 'trade lifecycle' do
    let!(:trade) { create(:trade) }
    let!(:trade_user_card) { create(:trade_user_card, trade: trade) }

    it 'is destroyed when trade is destroyed' do
      expect { trade.destroy }.to change(TradeUserCard, :count).by(-1)
    end
  end

  describe 'card version access' do
    let(:trade_user_card) { create(:trade_user_card) }

    it 'accesses card version through user_card' do
      expect(trade_user_card.user_card.card_version).to be_present
    end

    it 'accesses extension through card version' do
      expect(trade_user_card.user_card.card_version.extension).to be_present
    end
  end

  describe 'trade status transitions' do
    let(:trade_user_card) { create(:trade_user_card) }
    let(:trade) { trade_user_card.trade }

    it 'remains valid when trade is accepted' do
      trade.update(status: 'accepted')
      expect(trade_user_card.reload).to be_valid
    end

    it 'remains valid when trade is completed' do
      trade.update(status: 'done')
      expect(trade_user_card.reload).to be_valid
    end
  end
end
