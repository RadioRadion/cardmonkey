require 'rails_helper'

RSpec.describe CardVersion, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:card_id) }
    it { should validate_presence_of(:scryfall_id) }
    it { should validate_presence_of(:rarity) }
    it { should validate_presence_of(:frame) }
    it { should validate_presence_of(:border_color) }
    it { should validate_presence_of(:extension_id) }
  end

  describe 'associations' do
    it { should belong_to(:card) }
    it { should belong_to(:extension) }
    it { should have_many(:user_cards) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      card_version = build(:card_version)
      expect(card_version).to be_valid
    end
  end

  describe 'scopes' do
    let(:extension) { create(:extension) }
    let(:card) { create(:card) }
    let!(:card_version) { create(:card_version, extension: extension, card: card) }

    it 'can be filtered by extension' do
      expect(CardVersion.where(extension: extension)).to include(card_version)
    end

    it 'can be filtered by rarity' do
      expect(CardVersion.where(rarity: card_version.rarity)).to include(card_version)
    end
  end
end
