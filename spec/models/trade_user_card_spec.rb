require 'rails_helper'

RSpec.describe TradeUserCard, type: :model do
  describe 'associations' do
    it { should belong_to(:trade) }
    it { should belong_to(:user_card) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      trade_user_card = build_stubbed(:trade_user_card)
      expect(trade_user_card).to be_valid
    end
  end

  describe 'trade status' do
    let(:trade) { build_stubbed(:trade) }
    let(:trade_user_card) { build_stubbed(:trade_user_card, trade: trade) }

    before do
      allow(trade).to receive(:broadcast_replace_to)
    end

    it 'supports pending status' do
      trade.status = 'pending'
      expect(trade_user_card).to be_valid
    end

    it 'supports accepted status' do
      trade.status = 'accepted'
      expect(trade_user_card).to be_valid
    end

    it 'supports done status' do
      trade.status = 'done'
      expect(trade_user_card).to be_valid
    end
  end

  describe 'associations access' do
    let(:extension) { build_stubbed(:extension) }
    let(:card) { build_stubbed(:card) }
    let(:card_version) { build_stubbed(:card_version, extension: extension, card: card) }
    let(:user_card) { build_stubbed(:user_card, card_version: card_version) }
    let(:trade_user_card) { build_stubbed(:trade_user_card, user_card: user_card) }

    it 'accesses card version' do
      expect(trade_user_card.user_card.card_version).to eq(card_version)
    end

    it 'accesses extension' do
      expect(trade_user_card.user_card.card_version.extension).to eq(extension)
    end

    it 'accesses card' do
      expect(trade_user_card.user_card.card_version.card).to eq(card)
    end
  end

  describe 'deletion' do
    it 'is destroyed when trade is destroyed' do
      trade = create(:trade)
      trade_user_card = create(:trade_user_card, trade: trade)
      
      expect { trade.destroy }.to change(TradeUserCard, :count).by(-1)
    end
  end
end
