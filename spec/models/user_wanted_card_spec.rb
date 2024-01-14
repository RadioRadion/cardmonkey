# spec/models/user_wanted_card_spec.rb

require 'rails_helper'

RSpec.describe UserWantedCard, type: :model do
  context 'validations' do
    # Si des validations sont spécifiées dans le modèle UserWantedCard
    # it { should validate_presence_of(:some_attribute) }
  end

  context 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:card) }
    it { should have_many(:matches) }
  end

  # Tests pour les énumérations et méthodes personnalisées
end
