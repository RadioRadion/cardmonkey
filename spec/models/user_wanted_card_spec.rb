require 'rails_helper'

RSpec.describe UserWantedCard, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:quantity) }
    it { should validate_presence_of(:min_condition) }
    it { should validate_presence_of(:language) }
    it { should validate_inclusion_of(:foil).in_array([true, false]) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:card) }
    it { should belong_to(:card_version).optional }
    it { should have_many(:matches) }
  end

  describe 'enums' do
    it do
      should define_enum_for(:min_condition).with_values(
        poor: "0",
        played: "1",
        light_played: "2",
        good: "3",
        excellent: "4",
        near_mint: "5",
        mint: "6",
        unimportant: "7"
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
        corréen: "9",
        dont_care: "10"
      )
    end
  end

  describe '#name_en' do
    let(:card) { create(:card, name_en: 'Lightning Bolt') }
    let(:wanted_card) { create(:user_wanted_card, card: card) }

    it 'returns the english name of the associated card' do
      expect(wanted_card.name_en).to eq('Lightning Bolt')
    end
  end

  describe '#name_fr' do
    let(:card) { create(:card, name_fr: 'Éclair') }
    let(:wanted_card) { create(:user_wanted_card, card: card) }

    it 'returns the french name of the associated card' do
      expect(wanted_card.name_fr).to eq('Éclair')
    end
  end

  describe '#img_want_uri' do
    let(:card) { create(:card) }
    let(:card_version) { create(:card_version, card: card, img_uri: 'specific_version.jpg') }
    
    context 'when card_version is specified' do
      let(:wanted_card) { create(:user_wanted_card, card: card, card_version: card_version) }

      it 'returns the image URI of the specified version' do
        expect(wanted_card.img_want_uri).to eq('specific_version.jpg')
      end
    end

    context 'when no card_version is specified' do
      let!(:default_version) { create(:card_version, card: card, img_uri: 'default_version.jpg') }
      let(:wanted_card) { create(:user_wanted_card, card: card, card_version: nil) }

      it 'returns the image URI of the first version' do
        expect(wanted_card.img_want_uri).to eq('default_version.jpg')
      end
    end
  end

  describe 'matching behavior' do
    let(:user) { create(:user) }
    let(:card) { create(:card) }
    let(:card_version) { create(:card_version, card: card) }
    
    context 'with specific version requirement' do
      let(:wanted_card) do
        create(:user_wanted_card,
          user: user,
          card: card,
          card_version: card_version,
          min_condition: 'near_mint',
          language: 'français'
        )
      end

      it 'can be matched with exact version' do
        matching_card = create(:user_card,
          card_version: card_version,
          condition: 'mint',
          language: 'français'
        )
        expect { matching_card.check_matches }.to change(Match, :count).by(1)
      end
    end

    context 'with flexible requirements' do
      let(:wanted_card) do
        create(:user_wanted_card,
          user: user,
          card: card,
          min_condition: 'unimportant',
          language: 'dont_care'
        )
      end

      it 'matches with any version of the card' do
        versions = create_list(:card_version, 3, card: card)
        versions.each do |version|
          matching_card = create(:user_card,
            card_version: version,
            condition: 'played',
            language: 'anglais'
          )
          expect { matching_card.check_matches }.to change(Match, :count).by(1)
        end
      end
    end
  end
end
