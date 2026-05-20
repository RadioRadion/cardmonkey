require 'rails_helper'

RSpec.describe UserCard, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:card_version) }
    it { should have_many(:matches).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:quantity) }
    it { should validate_presence_of(:condition) }
    it { should validate_presence_of(:language) }
    it { should validate_inclusion_of(:foil).in_array([true, false]) }
  end

  describe 'enums' do
    it { should define_enum_for(:condition).with_values(
      poor: 'poor',
      played: 'played',
      light_played: 'light_played',
      good: 'good',
      excellent: 'excellent',
      near_mint: 'near_mint',
      mint: 'mint'
    ).backed_by_column_of_type(:string) }

    it { should define_enum_for(:language).with_values(
      french: 'fr',
      english: 'en',
      german: 'de',
      italian: 'it',
      simplified_chinese: 'zhs',
      traditional_chinese: 'zht',
      japanese: 'ja',
      portuguese: 'pt',
      russian: 'ru',
      korean: 'ko'
    ).backed_by_column_of_type(:string) }
  end

  describe 'callbacks' do
    describe 'after_create' do
      let(:user_card) { build(:user_card) }

      it 'creates matches after creation' do
        expect(user_card).to receive(:create_matches)
        user_card.save
      end
    end

    describe 'after_update' do
      let(:user_card) { create(:user_card) }

      context 'when relevant attributes change' do
        before do
          allow(user_card).to receive(:relevant_attributes_changed?).and_return(true)
        end

        it 'updates matches' do
          expect(user_card).to receive(:update_matches)
          user_card.save
        end
      end

      context 'when relevant attributes do not change' do
        before do
          allow(user_card).to receive(:relevant_attributes_changed?).and_return(false)
        end

        it 'does not update matches' do
          expect(user_card).not_to receive(:update_matches)
          user_card.save
        end
      end
    end
  end

  describe 'private methods' do
    describe '#relevant_attributes_changed?' do
      let(:user_card) { create(:user_card, :english) }

      it 'returns true when condition changes' do
        user_card.update(condition: 'mint')
        expect(user_card.send(:relevant_attributes_changed?)).to be true
      end

      it 'returns true when language changes' do
        user_card.update(language: 'fr')
        expect(user_card.send(:relevant_attributes_changed?)).to be true
      end

      it 'returns true when card_version_id changes' do
        new_card_version = create(:card_version)
        user_card.update(card_version_id: new_card_version.id)
        expect(user_card.send(:relevant_attributes_changed?)).to be true
      end

      it 'returns false when other attributes change' do
        original_quantity = user_card.quantity
        user_card.update(quantity: original_quantity + 1)
        expect(user_card.send(:relevant_attributes_changed?)).to be false
      end
    end
  end
end
