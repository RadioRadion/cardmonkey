require 'rails_helper'

RSpec.describe CardVersion, type: :model do
  describe 'associations' do
    it { should belong_to(:card) }
    it { should belong_to(:extension) }
    it { should have_many(:user_cards) }
  end

  describe 'validations' do
    it { should validate_presence_of(:card_id) }
    it { should validate_presence_of(:scryfall_id) }
    it { should validate_presence_of(:rarity) }
    it { should validate_presence_of(:frame) }
    it { should validate_presence_of(:border_color) }
    it { should validate_presence_of(:extension_id) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      card_version = build(:card_version)
      expect(card_version).to be_valid
    end

    describe 'traits' do
      it 'creates user cards with :with_user_cards trait' do
        card_version = create(:card_version, :with_user_cards)
        expect(card_version.user_cards.count).to eq(3)
      end

      it 'creates common rarity with :common trait' do
        card_version = create(:card_version, :common)
        expect(card_version.rarity).to eq('common')
      end

      it 'creates uncommon rarity with :uncommon trait' do
        card_version = create(:card_version, :uncommon)
        expect(card_version.rarity).to eq('uncommon')
      end

      it 'creates rare rarity with :rare trait' do
        card_version = create(:card_version, :rare)
        expect(card_version.rarity).to eq('rare')
      end

      it 'creates mythic rarity with :mythic trait' do
        card_version = create(:card_version, :mythic)
        expect(card_version.rarity).to eq('mythic')
      end
    end
  end

  describe 'attributes' do
    let(:card_version) { build(:card_version) }

    it 'has a valid scryfall_id format' do
      expect(card_version.scryfall_id).to match(/^scryfall-\d+$/)
    end

    it 'has a valid frame value' do
      expect(['1993', '1997', '2003', '2015', 'future']).to include(card_version.frame)
    end

    it 'has a valid border_color value' do
      expect(['black', 'white', 'borderless', 'silver', 'gold']).to include(card_version.border_color)
    end

    it 'has a valid rarity value' do
      expect(['common', 'uncommon', 'rare', 'mythic']).to include(card_version.rarity)
    end
  end
end
