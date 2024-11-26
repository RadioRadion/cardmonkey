require 'rails_helper'

RSpec.describe Card, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:scryfall_oracle_id) }
    it { should validate_presence_of(:name_fr) }
    it { should validate_presence_of(:name_en) }
  end

  describe 'associations' do
    it { should have_many(:user_wanted_cards) }
    it { should have_many(:card_versions) }
  end

  describe '#name' do
    let(:card) { build_stubbed(:card, name_fr: 'Lotus Noir', name_en: 'Black Lotus') }

    context 'when preferred language is English' do
      it 'returns the English name' do
        expect(card.name(:en)).to eq('Black Lotus')
      end
    end

    context 'when preferred language is French' do
      it 'returns the French name' do
        expect(card.name(:fr)).to eq('Lotus Noir')
      end
    end

    context 'when preferred language is not supported' do
      it 'returns the English name as default' do
        expect(card.name(:es)).to eq('Black Lotus')
      end
    end

    context 'when no language is specified' do
      it 'returns the English name as default' do
        expect(card.name).to eq('Black Lotus')
      end
    end
  end
end
