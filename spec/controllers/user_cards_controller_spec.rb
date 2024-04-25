require 'rails_helper'

RSpec.describe UserCardsController, type: :controller do
  let(:user) { FactoryBot.create(:user) }
  let(:card_version) { FactoryBot.create(:card_version) }
  let(:valid_attributes) {
    { scryfall_id: card_version.scryfall_id, condition: 'good', foil: false, language: '2', quantity: 1, card_version_id: card_version.id }
  }
  let(:invalid_attributes) {
    { scryfall_id: nil, condition: nil, foil: nil, language: nil, quantity: nil }
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
      it "creates a new UserCard and redirects to the user's card list" do
        expect {
          post :create, params: {user_id: user.id, user_card: valid_attributes}
        }.to change(UserCard, :count).by(1)
        expect(response).to redirect_to(user_user_cards_path(user))
      end
    end

    context "with invalid params" do
      it "returns a new template with unprocessable_entity status" do
        post :create, params: {user_id: user.id, user_card: invalid_attributes}
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end    
  end

  describe "GET #edit" do
    it "returns a success response" do
      user_card = FactoryBot.create(:user_card, user: user)
      get :edit, params: {user_id: user.id, id: user_card.id}
      expect(response).to be_successful
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        { quantity: 3 }
      }

      it "updates the requested user_card" do
        user_card = FactoryBot.create(:user_card, user: user)
        put :update, params: {user_id: user.id, id: user_card.id, user_card: new_attributes}
        user_card.reload
        expect(user_card.quantity).to eq(3)
        expect(response).to redirect_to(user_user_cards_path(user))
      end
    end

    context "with invalid params" do
      it "returns an edit template with unprocessable_entity status" do
        user_card = FactoryBot.create(:user_card, user: user)
        put :update, params: {user_id: user.id, id: user_card.id, user_card: invalid_attributes}
        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash[:alert] || flash[:notice]).to be_present
      end
    end  
  end

  describe "DELETE #destroy" do
    it "destroys the requested user_card" do
      user_card = FactoryBot.create(:user_card, user: user)
      expect {
        delete :destroy, params: {user_id: user.id, id: user_card.id}
      }.to change(UserCard, :count).by(-1)
      expect(response).to redirect_to(user_user_cards_url(user))
    end
  end
end
