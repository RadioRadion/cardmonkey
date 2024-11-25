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
    let(:card) { build(:card, name_fr: 'Lotus Noir', name_en: 'Black Lotus') }

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

  describe '.fetch_cards' do
    let(:mock_response) do
      {
        'data' => [
          {
            'id' => 'test-id',
            'image_uris' => { 'border_crop' => 'https://example.com/image.jpg' },
            'set' => 'test-set',
            'name' => 'Test Card',
            'prices' => { 'eur' => '1.99' }
          }
        ]
      }.to_json
    end

    before do
      stub_request(:get, /api.scryfall.com/)
        .to_return(status: 200, body: mock_response, headers: { 'Content-Type' => 'application/json' })
      
      allow(Down).to receive(:download).and_return(double(path: 'temp/path'))
      allow(FileUtils).to receive(:mv)
    end

    it 'creates cards from the Scryfall API response' do
      expect {
        Card.fetch_cards('test-set')
      }.to change(Card, :count).by(1)
    end

    it 'downloads and saves card images' do
      Card.fetch_cards('test-set')
      expect(Down).to have_received(:download)
      expect(FileUtils).to have_received(:mv)
    end

    context 'when API request fails' do
      before do
        stub_request(:get, /api.scryfall.com/)
          .to_return(status: 404)
      end

      it 'raises an error' do
        expect {
          Card.fetch_cards('test-set')
        }.to raise_error(JSON::ParserError)
      end
    end
  end
end
