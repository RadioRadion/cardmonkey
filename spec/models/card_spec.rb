# spec/models/card_spec.rb

require 'rails_helper'

RSpec.describe Card, type: :model do
  context 'validations' do
    it 'is valid with valid attributes' do
      card = Card.new(name_en: 'Black Lotus', name_fr: 'Lotus Noir', extension: 'Alpha')
      expect(card).to be_valid
    end

    it 'is not valid without an extension' do
      card = Card.new(name_en: 'Black Lotus', name_fr: 'Lotus Noir')
      expect(card).not_to be_valid
    end
  end

  context 'associations' do
    it { should have_many(:user_cards) }
    it { should have_many(:user_wanted_cards) }
  end

  # Autres tests, y compris pour la méthode de classe fetch_cards
  # ...
end
