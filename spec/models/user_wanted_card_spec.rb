# spec/models/user_wanted_card_spec.rb
require 'rails_helper'

RSpec.describe UserWantedCard, type: :model do
  # Associations
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:card) }
    it { should belong_to(:card_version).optional }
    it { should have_many(:matches).dependent(:destroy) }
  end

  # Validations
  describe 'validations' do
    it { should validate_presence_of(:quantity) }
    it { should validate_presence_of(:min_condition) }
    it { should validate_presence_of(:language) }
    it { should allow_value(true, false).for(:foil) }
  end

  # Enums
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

  # Scopes
  describe 'scopes' do
    let!(:wanted_card1) { create(:user_wanted_card, min_condition: 'good', language: 'french') }
    let!(:wanted_card2) { create(:user_wanted_card, min_condition: 'mint', language: 'english') }
    
    describe '.by_min_condition' do
      it 'filters by minimum condition' do
        expect(described_class.by_min_condition('good')).to include(wanted_card1)
        expect(described_class.by_min_condition('good')).not_to include(wanted_card2)
      end
    end

    describe '.by_language' do
      it 'filters by language' do
        expect(described_class.by_language('french')).to include(wanted_card1)
        expect(described_class.by_language('french')).not_to include(wanted_card2)
      end
    end

    describe '.with_matches' do
      let!(:match) { create(:match, user_wanted_card: wanted_card1) }

      it 'returns cards with matches' do
        expect(described_class.with_matches).to include(wanted_card1)
        expect(described_class.with_matches).not_to include(wanted_card2)
      end
    end

    describe '.without_matches' do
      let!(:match) { create(:match, user_wanted_card: wanted_card1) }

      it 'returns cards without matches' do
        expect(described_class.without_matches).not_to include(wanted_card1)
        expect(described_class.without_matches).to include(wanted_card2)
      end
    end
  end

  # Instance Methods
  describe 'instance methods' do
    let(:wanted_card) { create(:user_wanted_card) }

    describe '#matches_count' do
      it 'returns the correct number of matches' do
        create_list(:match, 3, user_wanted_card: wanted_card)
        expect(wanted_card.matches_count).to eq(3)
      end
    end

    describe '#potential_matches_count' do
      let(:user) { create(:user) }
      let(:card) { create(:card) }
      let(:wanted_card) { create(:user_wanted_card, user: user, card: card, min_condition: 'good', language: 'french') }

      it 'returns the count of potential matches' do
        # Create matching card
        create(:user_card, 
          user: create(:user), 
          card_version: create(:card_version, card: card),
          condition: 'near_mint',
          language: 'french'
        )

        expect(wanted_card.potential_matches_count).to eq(1)
      end
    end

    describe '#img_uri' do
      context 'when card_version is present' do
        let(:card_version) { create(:card_version, img_uri: 'specific_version.jpg') }
        let(:wanted_card) { create(:user_wanted_card, card_version: card_version) }

        it 'returns the card version image URI' do
          expect(wanted_card.img_uri).to eq('specific_version.jpg')
        end
      end

      context 'when only card is present' do
        let(:card) { create(:card) }
        let(:card_version) { create(:card_version, card: card, img_uri: 'first_version.jpg') }
        let(:wanted_card) { create(:user_wanted_card, card: card) }

        before { card_version } # Ensure card version exists

        it 'returns the first card version image URI' do
          expect(wanted_card.img_uri).to eq('first_version.jpg')
        end
      end
    end
  end

  # Matching Logic
  describe 'matching logic' do
    let(:user) { create(:user) }
    let(:card) { create(:card) }
    let(:card_version) { create(:card_version, card: card) }

    describe '#create_matches' do
      let(:wanted_card) { build(:user_wanted_card, 
        user: user,
        card: card,
        min_condition: 'good',
        language: 'french'
      )}

      context 'when matching cards exist' do
        before do
          create(:user_card,
            user: create(:user),
            card_version: card_version,
            condition: 'near_mint',
            language: 'french'
          )
        end

        it 'creates matches after creation' do
          expect { wanted_card.save! }.to change(Match, :count).by(1)
        end
      end

      context 'with unimportant condition' do
        let(:wanted_card) { build(:user_wanted_card,
          user: user,
          card: card,
          min_condition: 'unimportant',
          language: 'french'
        )}

        it 'matches cards regardless of condition' do
          create(:user_card,
            user: create(:user),
            card_version: card_version,
            condition: 'poor',
            language: 'french'
          )

          expect { wanted_card.save! }.to change(Match, :count).by(1)
        end
      end

      context 'with any language' do
        let(:wanted_card) { build(:user_wanted_card,
          user: user,
          card: card,
          min_condition: 'good',
          language: 'any'
        )}

        it 'matches cards regardless of language' do
          create(:user_card,
            user: create(:user),
            card_version: card_version,
            condition: 'near_mint',
            language: 'japanese'
          )

          expect { wanted_card.save! }.to change(Match, :count).by(1)
        end
      end
    end

    describe '#update_matches' do
      let!(:wanted_card) { create(:user_wanted_card) }
      let!(:match) { create(:match, user_wanted_card: wanted_card) }

      it 'recreates matches when min_condition changes' do
        expect {
          wanted_card.update!(min_condition: 'mint')
        }.to change(Match, :count)
      end

      it 'recreates matches when language changes' do
        expect {
          wanted_card.update!(language: 'english')
        }.to change(Match, :count)
      end

      it 'does not recreate matches when quantity changes' do
        expect {
          wanted_card.update!(quantity: 5)
        }.not_to change(Match, :count)
      end
    end
  end
end