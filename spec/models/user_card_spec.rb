# spec/models/user_card_spec.rb

require 'rails_helper'

RSpec.describe UserCard, type: :model do
  context 'validations' do
    # Si des validations sont spécifiées dans le modèle UserCard
    # it { should validate_presence_of(:some_attribute) }
  end

  context 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:card) }
    it { should have_many(:matches) }
  end

  # Tests pour les énumérations et méthodes personnalisées
end
