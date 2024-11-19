require 'rails_helper'

RSpec.describe Extension, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:code) }
    it { should validate_presence_of(:release_date) }
    it { should validate_uniqueness_of(:code) }
  end

  describe 'associations' do
    it { should have_many(:card_versions) }
  end

  describe 'scopes' do
    let!(:future_extension) { create(:extension, :future_release) }
    let!(:past_extension) { create(:extension, :past_release) }
    let!(:current_extension) { create(:extension, release_date: Date.current) }

    describe '.released' do
      it 'includes past and current extensions' do
        released = Extension.released
        expect(released).to include(past_extension, current_extension)
        expect(released).not_to include(future_extension)
      end
    end

    describe '.upcoming' do
      it 'includes only future extensions' do
        upcoming = Extension.upcoming
        expect(upcoming).to include(future_extension)
        expect(upcoming).not_to include(past_extension, current_extension)
      end
    end
  end

  describe 'card versions statistics' do
    let(:extension) { create(:extension) }

    before do
      create_list(:card_version, 2, extension: extension, rarity: 'common')
      create_list(:card_version, 2, extension: extension, rarity: 'uncommon')
      create(:card_version, extension: extension, rarity: 'rare')
      create(:card_version, extension: extension, rarity: 'mythic')
    end

    it 'counts total cards correctly' do
      expect(extension.card_versions.count).to eq(6)
    end

    it 'groups cards by rarity correctly' do
      rarity_counts = extension.card_versions.group(:rarity).count
      expect(rarity_counts).to eq({
        'common' => 2,
        'uncommon' => 2,
        'rare' => 1,
        'mythic' => 1
      })
    end
  end

  describe 'ordering' do
    let!(:extension1) { create(:extension, release_date: 1.year.ago) }
    let!(:extension2) { create(:extension, release_date: 6.months.ago) }
    let!(:extension3) { create(:extension, release_date: 1.month.ago) }

    it 'orders by release date by default' do
      expect(Extension.all).to eq([extension1, extension2, extension3])
    end
  end

  describe 'card management' do
    let(:extension) { create(:extension) }
    let(:cards) { create_list(:card, 3) }

    it 'can have multiple versions of the same card' do
      cards.each do |card|
        create_list(:card_version, 2, card: card, extension: extension)
      end

      expect(extension.card_versions.count).to eq(6)
      expect(extension.card_versions.map(&:card).uniq.count).to eq(3)
    end

    it 'tracks unique cards correctly' do
      cards.each do |card|
        create(:card_version, card: card, extension: extension)
      end

      expect(extension.card_versions.count).to eq(3)
      expect(extension.card_versions.map(&:card).uniq.count).to eq(3)
    end
  end
end
