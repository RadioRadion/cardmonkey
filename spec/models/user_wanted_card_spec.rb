require 'rails_helper'

RSpec.describe UserWantedCard, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:card) }
    it { should belong_to(:card_version).optional }
    it { should have_many(:matches).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:quantity) }
    it { should validate_presence_of(:min_condition) }
    it { should validate_presence_of(:language) }
    it { should validate_inclusion_of(:foil).in_array([true, false]) }
  end

  describe 'enums' do
    it { should define_enum_for(:min_condition).with_values(
      poor: 'poor',
      played: 'played',
      light_played: 'light_played',
      good: 'good',
      excellent: 'excellent',
      near_mint: 'near_mint',
      mint: 'mint',
      unimportant: 'unimportant'
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
      korean: 'ko',
      any: 'any'
    ).backed_by_column_of_type(:string) }
  end

  describe 'scopes' do
    let!(:good_condition_card) { create(:user_wanted_card, min_condition: 'good') }
    let!(:mint_condition_card) { create(:user_wanted_card, min_condition: 'mint') }
    let!(:french_card) { create(:user_wanted_card, language: 'french') }
    let!(:english_card) { create(:user_wanted_card, language: 'english') }
    let!(:card_with_matches) { create(:user_wanted_card, :with_matches) }
    let!(:card_without_matches) { create(:user_wanted_card) }

    describe '.by_min_condition' do
      it 'returns cards with specified minimum condition' do
        expect(described_class.by_min_condition('good')).to include(good_condition_card)
        expect(described_class.by_min_condition('good')).not_to include(mint_condition_card)
      end
    end

    describe '.by_language' do
      it 'returns cards with specified language' do
        expect(described_class.by_language('french')).to include(french_card)
        expect(described_class.by_language('french')).not_to include(english_card)
      end
    end

    describe '.with_matches' do
      it 'returns cards that have matches' do
        expect(described_class.with_matches).to include(card_with_matches)
        expect(described_class.with_matches).not_to include(card_without_matches)
      end
    end

    describe '.without_matches' do
      it 'returns cards that have no matches' do
        expect(described_class.without_matches).to include(card_without_matches)
        expect(described_class.without_matches).not_to include(card_with_matches)
      end
    end
  end

  describe 'instance methods' do
    let(:user_wanted_card) { create(:user_wanted_card) }
    let(:card_version) { create(:card_version) }
    let(:user_wanted_card_with_version) { create(:user_wanted_card, card_version: card_version) }

    describe '#matches_count' do
      it 'returns the number of matches' do
        create_list(:match, 3, user_wanted_card: user_wanted_card)
        expect(user_wanted_card.matches_count).to eq(3)
      end
    end

    describe '#potential_matches_count' do
      it 'returns the number of potential matches' do
        # Create some potential matches
        other_user = create(:user)
        matching_card = create(:user_card, 
          user: other_user,
          card: user_wanted_card.card,
          language: user_wanted_card.language,
          condition: user_wanted_card.min_condition
        )
        
        expect(user_wanted_card.potential_matches_count).to eq(1)
      end
    end

    describe '#img_uri' do
      context 'when card_version is present' do
        it 'returns the card version img_uri' do
          expect(user_wanted_card_with_version.img_uri).to eq(card_version.img_uri)
        end
      end

      context 'when card_version is not present' do
        it 'returns the first card version img_uri from the card' do
          first_version = create(:card_version, card: user_wanted_card.card)
          expect(user_wanted_card.img_uri).to eq(first_version.img_uri)
        end
      end
    end
  end

  describe 'callbacks' do
    describe 'after_create' do
      it 'creates matches' do
        other_user = create(:user)
        card = create(:card)
        matching_card = create(:user_card, 
          user: other_user,
          card: card,
          language: 'french',
          condition: 'good'
        )
        
        user_wanted_card = build(:user_wanted_card,
          card: card,
          language: 'french',
          min_condition: 'good'
        )
        
        expect { user_wanted_card.save }.to change(Match, :count).by(1)
      end
    end

    describe 'after_update' do
      let!(:user_wanted_card) { create(:user_wanted_card) }

      it 'updates matches when relevant attributes change' do
        expect(user_wanted_card).to receive(:update_matches)
        user_wanted_card.update(min_condition: 'mint')
      end

      it 'does not update matches when irrelevant attributes change' do
        expect(user_wanted_card).not_to receive(:update_matches)
        user_wanted_card.update(quantity: 2)
      end
    end
  end
end
