require 'rails_helper'

RSpec.describe Extension, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:code) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:release_date) }
    it { should validate_presence_of(:icon_uri) }
  end

  describe 'associations' do
    it { should have_many(:card_versions) }
  end

  describe 'factory' do
    context 'default factory' do
      let(:extension) { build(:extension) }

      it 'creates a valid extension' do
        expect(extension).to be_valid
      end

      it 'generates unique codes' do
        ext1 = create(:extension)
        ext2 = create(:extension)
        expect(ext1.code).not_to eq(ext2.code)
      end

      it 'generates unique names' do
        ext1 = create(:extension)
        ext2 = create(:extension)
        expect(ext1.name).not_to eq(ext2.name)
      end
    end

    context 'with_cards trait' do
      let(:extension) { create(:extension, :with_cards) }

      it 'creates associated card versions' do
        expect(extension.card_versions.count).to eq(3)
      end
    end

    context 'future_release trait' do
      let(:extension) { create(:extension, :future_release) }

      it 'sets release date in the future' do
        expect(extension.release_date).to be > Date.current
      end
    end

    context 'past_release trait' do
      let(:extension) { create(:extension, :past_release) }

      it 'sets release date in the past' do
        expect(extension.release_date).to be < Date.current
      end
    end

    context 'with_all_rarities trait' do
      let(:extension) { create(:extension, :with_all_rarities) }

      it 'creates card versions for all rarities' do
        rarities = extension.card_versions.pluck(:rarity).uniq.sort
        expect(rarities).to eq(['common', 'mythic', 'rare', 'uncommon'])
      end

      it 'sets appropriate prices for each rarity' do
        extension.card_versions.each do |cv|
          case cv.rarity
          when 'common'
            expect(cv.eur_price).to eq(0.02)
            expect(cv.eur_foil_price).to eq(0.10)
          when 'uncommon'
            expect(cv.eur_price).to eq(0.10)
            expect(cv.eur_foil_price).to eq(0.50)
          when 'rare'
            expect(cv.eur_price).to eq(1.00)
            expect(cv.eur_foil_price).to eq(3.00)
          when 'mythic'
            expect(cv.eur_price).to eq(5.00)
            expect(cv.eur_foil_price).to eq(15.00)
          end
        end
      end
    end

    context 'standard_legal trait' do
      let(:extension) { create(:extension, :standard_legal) }

      it 'creates card versions' do
        expect(extension.card_versions.count).to eq(3)
      end
    end

    context 'modern_legal trait' do
      let(:extension) { create(:extension, :modern_legal) }

      it 'creates card versions' do
        expect(extension.card_versions.count).to eq(3)
      end

      it 'sets release date to modern-legal timeframe' do
        expect(extension.release_date).to be <= 8.years.ago.to_date
      end
    end

    context 'vintage_legal trait' do
      let(:extension) { create(:extension, :vintage_legal) }

      it 'creates card versions' do
        expect(extension.card_versions.count).to eq(3)
      end

      it 'sets release date to vintage-legal timeframe' do
        expect(extension.release_date).to be <= 20.years.ago.to_date
      end
    end

    context 'complete_extension trait' do
      let(:extension) { create(:extension, :complete_extension) }

      it 'combines multiple traits effectively' do
        # Check for cards of all rarities
        rarities = extension.card_versions.pluck(:rarity).uniq.sort
        expect(rarities).to eq(['common', 'mythic', 'rare', 'uncommon'])

        # Check for additional special cards
        mythic_cards = extension.card_versions.where(rarity: 'mythic')
        rare_cards = extension.card_versions.where(rarity: 'rare')
        expect(mythic_cards).to exist
        expect(rare_cards).to exist
      end
    end
  end
end
