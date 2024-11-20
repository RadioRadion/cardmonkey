# spec/models/user_card_spec.rb
require 'rails_helper'

RSpec.describe UserCard, type: :model do
  # Associations
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:card_version) }
    it { should have_many(:matches).dependent(:destroy) }
  end

  # Validations
  describe 'validations' do
    it { should validate_presence_of(:quantity) }
    it { should validate_presence_of(:condition) }
    it { should validate_presence_of(:language) }
    it { should allow_value(true, false).for(:foil) }
  end

  # Enums
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

    it 'defaults condition to good' do
      user_card = build(:user_card, condition: nil)
      expect(user_card.condition).to eq('good')
    end
  end

  # Callbacks et Matching Logic
  describe 'matching logic' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:card_version) { create(:card_version) }
    
    describe '#create_matches' do
      let(:user_card) { build(:user_card, 
        user: user,
        card_version: card_version,
        condition: 'near_mint',
        language: 'french'
      )}

      context 'when matching wanted cards exist' do
        before do
          create(:user_wanted_card,
            user: other_user,
            card: card_version.card,
            min_condition: 'good',
            language: 'french'
          )
        end

        it 'creates matches after creation' do
          expect { user_card.save! }.to change(Match, :count).by(1)
        end
      end

      context 'when no matching wanted cards exist' do
        it 'does not create any matches' do
          expect { user_card.save! }.not_to change(Match, :count)
        end
      end
    end

    describe '#update_matches' do
      let!(:user_card) { create(:user_card, condition: 'near_mint') }
      let!(:match) { create(:match, user_card: user_card) }

      context 'when relevant attributes change' do
        it 'recreates matches when condition changes' do
          expect {
            user_card.update!(condition: 'good')
          }.to change(Match, :count)
        end

        it 'recreates matches when language changes' do
          expect {
            user_card.update!(language: 'english')
          }.to change(Match, :count)
        end
      end

      context 'when non-relevant attributes change' do
        it 'does not recreate matches when quantity changes' do
          expect {
            user_card.update!(quantity: 5)
          }.not_to change(Match, :count)
        end
      end
    end
  end

  # Helper Methods
  describe '#find_potential_matches' do
    let(:user_card) { create(:user_card, condition: 'near_mint', language: 'french') }

    it 'finds matches with exact language match' do
      wanted_card = create(:user_wanted_card, 
        language: 'french',
        min_condition: 'good'
      )
      matches = user_card.send(:find_potential_matches)
      expect(matches).to include(wanted_card)
    end

    it 'finds matches with no language preference' do
      wanted_card = create(:user_wanted_card, 
        language: nil,
        min_condition: 'good'
      )
      matches = user_card.send(:find_potential_matches)
      expect(matches).to include(wanted_card)
    end

    it 'excludes matches with insufficient condition' do
      wanted_card = create(:user_wanted_card, 
        min_condition: 'mint'
      )
      matches = user_card.send(:find_potential_matches)
      expect(matches).not_to include(wanted_card)
    end
  end
end