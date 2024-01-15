# spec/models/user_spec.rb

require 'rails_helper'

RSpec.describe User, type: :model do
  context 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:password) }
  end

  context 'associations' do
    it { should have_many(:trades) }
    it { should have_many(:messages) }
    it { should have_many(:chatrooms).through(:messages) }
    it { should have_many(:user_cards) }
    it { should have_many(:cards).through(:user_cards) }
    it { should have_many(:user_wanted_cards) }
    it { should have_many(:matches) }
    it { should have_many(:notifications) }
  end

  describe '#find_card_matches' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:card) { create(:card) }

    before do
      # Créer une liste de souhaits pour l'utilisateur
      create(:user_wanted_card, user: user, card: card)

      # Créer une carte dans la collection de l'autre utilisateur
      create(:user_card, user: other_user, card: card)
    end

    context 'when preference is value_based' do
      it 'returns matches sorted by card value' do
        user.value_based!
        matches = user.find_card_matches
        expect(matches.first.card).to eq(card)
        # Ajoutez plus d'assertions si nécessaire pour vérifier le tri par valeur
      end
    end

    context 'when preference is quantity_based' do
      it 'returns matches sorted by quantity' do
        user.quantity_based!
        matches = user.find_card_matches
        expect(matches.count).to eq(1)
        expect(matches.first.user).to eq(other_user)
        # Ajoutez plus d'assertions si nécessaire pour vérifier le tri par quantité
      end
    end

    # Vous pouvez ajouter d'autres contextes ou tests selon vos besoins
  end
end
