require 'rails_helper'

RSpec.describe UserCard, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:quantity) }
    it { should validate_presence_of(:condition) }
    it { should validate_presence_of(:language) }
    it { should validate_inclusion_of(:foil).in_array([true, false]) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:card_version) }
    it { should have_many(:matches) }
  end

  describe 'enums' do
    it do
      should define_enum_for(:condition).with_values(
        poor: "0",
        played: "1",
        light_played: "2",
        good: "3",
        excellent: "4",
        near_mint: "5",
        mint: "6"
      )
    end

    it do
      should define_enum_for(:language).with_values(
        français: "0",
        anglais: "1",
        allemand: "2",
        italien: "3",
        chinois_s: "4",
        chinois_t: "5",
        japonais: "6",
        portuguais: "7",
        russe: "8",
        corréen: "9"
      )
    end
  end

  describe 'callbacks' do
    describe '#create_matches' do
      let(:user) { create(:user) }
      let(:other_user) { create(:user) }
      let(:card_version) { create(:card_version) }

      context 'when creating a new user_card' do
        context 'with matching wanted cards' do
          let!(:user_wanted_card) do
            create(:user_wanted_card,
              user: other_user,
              card: card_version.card,
              language: 'french',
              min_condition: 'good'
            )
          end

          it 'creates a match' do
            expect {
              create(:user_card,
                user: user,
                card_version: card_version,
                language: 'french',
                condition: 'near_mint'
              )
            }.to change(Match, :count).by(1)
          end
        end

        context 'with non-matching wanted cards' do
          let!(:user_wanted_card) do
            create(:user_wanted_card,
              user: other_user,
              card: card_version.card,
              language: 'french',
              min_condition: 'near_mint'
            )
          end

          it 'does not create a match for worse condition' do
            expect {
              create(:user_card,
                user: user,
                card_version: card_version,
                language: 'french',
                condition: 'good'
              )
            }.not_to change(Match, :count)
          end
        end

        context 'with wrong language' do
          let!(:user_wanted_card) do
            create(:user_wanted_card,
              user: other_user,
              card: card_version.card,
              language: 'english',
              min_condition: 'good'
            )
          end

          it 'does not create a match' do
            expect {
              create(:user_card,
                user: user,
                card_version: card_version,
                language: 'french',
                condition: 'near_mint'
              )
            }.not_to change(Match, :count)
          end
        end
      end
    end

    describe '#update_matches' do
      let(:user_card) { create(:user_card, condition: 'near_mint', language: 'french') }
      let!(:match) { create(:match, user_card: user_card) }

      context 'when updating relevant attributes' do
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

      context 'when updating non-relevant attributes' do
        it 'does not recreate matches when quantity changes' do
          expect {
            user_card.update!(quantity: 2)
          }.not_to change(Match, :count)
        end
      end
    end
  end

  describe 'scopes' do
    let!(:near_mint_card) { create(:user_card, condition: 'near_mint') }
    let!(:good_card) { create(:user_card, condition: 'good') }
    let!(:french_card) { create(:user_card, language: 'french') }
    let!(:english_card) { create(:user_card, language: 'english') }

    describe '.by_condition' do
      it 'filters cards by condition' do
        expect(UserCard.by_condition('near_mint')).to include(near_mint_card)
        expect(UserCard.by_condition('near_mint')).not_to include(good_card)
      end
    end

    describe '.by_language' do
      it 'filters cards by language' do
        expect(UserCard.by_language('french')).to include(french_card)
        expect(UserCard.by_language('french')).not_to include(english_card)
      end
    end
  end
end
