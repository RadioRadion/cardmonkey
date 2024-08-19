require 'rails_helper'

RSpec.describe UserWantedCardsController, type: :controller do
  let(:user) { FactoryBot.create(:user) }
  let(:card) { FactoryBot.create(:card) } # Assurez-vous que cette factory existe
  let(:card_version) { FactoryBot.create(:card_version, card: card) } # Reliez card_version à card
  let(:valid_attributes) {
    { scryfall_oracle_id: card.scryfall_oracle_id, card_version_id: card_version.id, min_condition: 'good', foil: false, language: '2', quantity: 1 }
  }
  let(:invalid_attributes) {
    { scryfall_oracle_id: nil, card_version_id: nil, min_condition: nil, foil: nil, language: nil, quantity: nil }
  }

  before(:each) do
    sign_in user
  end

  describe "GET #index" do
    it "returns a success response" do
      get :index, params: {user_id: user.id}
      expect(response).to be_successful
    end
  end

  describe "GET #new" do
    it "returns a success response" do
      get :new, params: {user_id: user.id}
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new UserWantedCard and redirects to the index" do
        expect {
          post :create, params: {user_id: user.id, user_wanted_card: valid_attributes}
        }.to change(UserWantedCard, :count).by(1)
        expect(response).to redirect_to(user_user_wanted_cards_path(user))
      end
    end

    context "with invalid params" do
      it "does not create and re-renders the 'new' template" do
        post :create, params: {user_id: user.id, user_wanted_card: invalid_attributes}
        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash[:alert]).to be_present
      end
    end    
  end

  describe "GET #edit" do
    it "returns a success response" do
      user_wanted_card = FactoryBot.create(:user_wanted_card, user: user)
      get :edit, params: { user_id: user.id, id: user_wanted_card.id }
      expect(response).to be_successful
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        { quantity: 3 }
      }

      it "updates the requested user_wanted_card and redirects" do
        user_wanted_card = FactoryBot.create(:user_wanted_card, user: user)
        put :update, params: { user_id: user.id, id: user_wanted_card.id, user_wanted_card: new_attributes }
        user_wanted_card.reload
        expect(user_wanted_card.quantity).to eq(3)
        expect(response).to redirect_to(user_user_wanted_cards_path(user))
      end
    end

    context "with invalid params" do
      it "does not update and re-renders the 'edit' template" do
        user_wanted_card = FactoryBot.create(:user_wanted_card, user: user)
        put :update, params: { user_id: user.id, id: user_wanted_card.id, user_wanted_card: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash[:alert] || flash[:notice]).to be_present
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested user_wanted_card and redirects" do
      user_wanted_card = FactoryBot.create(:user_wanted_card, user: user)
      expect {
        delete :destroy, params: { user_id: user.id, id: user_wanted_card.id }
      }.to change(UserWantedCard, :count).by(-1)
      expect(response).to redirect_to(user_user_wanted_cards_path(user))
    end
  end
end
