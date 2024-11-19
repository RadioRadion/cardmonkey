require 'rails_helper'

RSpec.describe Card, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:scryfall_oracle_id) }
    it { should validate_presence_of(:name_fr) }
    it { should validate_presence_of(:name_en) }
    it { should validate_uniqueness_of(:scryfall_oracle_id) }
  end

  describe 'associations' do
    it { should have_many(:user_wanted_cards) }
    it { should have_many(:card_versions) }
  end

  describe '#name' do
    let(:card) { create(:card, name_fr: 'Contresort', name_en: 'Counterspell') }

    context 'with default language' do
      it 'returns english name' do
        expect(card.name).to eq('Counterspell')
      end
    end

    context 'with french language' do
      it 'returns french name' do
        expect(card.name(:fr)).to eq('Contresort')
      end
    end

    context 'with english language' do
      it 'returns english name' do
        expect(card.name(:en)).to eq('Counterspell')
      end
    end

    context 'with invalid language' do
      it 'returns english name' do
        expect(card.name(:invalid)).to eq('Counterspell')
      end
    end
  end

  describe 'card versions' do
    let(:card) { create(:card) }
    let(:extension) { create(:extension) }

    it 'can have multiple versions' do
      create_list(:card_version, 3, card: card, extension: extension)
      expect(card.card_versions.count).to eq(3)
    end

    it 'can have versions from different extensions' do
      extensions = create_list(:extension, 3)
      extensions.each do |ext|
        create(:card_version, card: card, extension: ext)
      end
      expect(card.card_versions.map(&:extension)).to match_array(extensions)
    end
  end

  describe 'user wanted cards' do
    let(:card) { create(:card) }
    let(:users) { create_list(:user, 3) }

    it 'can be wanted by multiple users' do
      users.each do |user|
        create(:user_wanted_card, card: card, user: user)
      end
      expect(card.user_wanted_cards.count).to eq(3)
      expect(card.user_wanted_cards.map(&:user)).to match_array(users)
    end
  end
end
