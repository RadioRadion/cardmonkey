RSpec.describe Card, type: :model do
  let(:card) { FactoryBot.create(:card) }

  describe 'associations' do
    it { should have_many(:user_wanted_cards) }
    it { should have_many(:card_versions) }
  end

  describe '#name' do
    context 'when preferred language is English' do
      it 'returns the English name' do
        expect(card.name(:en)).to eq(card.name_en)
      end
    end

    context 'when preferred language is French' do
      it 'returns the French name' do
        expect(card.name(:fr)).to eq(card.name_fr)
      end
    end

    context 'when no preferred language is specified' do
      it 'defaults to English' do
        expect(card.name).to eq(card.name_en)
      end
    end
  end
end
