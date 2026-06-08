require "rails_helper"

RSpec.describe "Onboarding & FAQ", type: :request do
  describe "FAQ" do
    it "is publicly accessible" do
      get faq_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "sign up" do
    it "collects the address so geocoding can run" do
      expect do
        post user_registration_path, params: {
          user: {
            email: "newbie@example.com",
            password: "password123",
            password_confirmation: "password123",
            address: "Lyon, France"
          }
        }
      end.to change(User, :count).by(1)

      expect(User.last.address).to eq("Lyon, France")
    end
  end

  describe "dashboard onboarding checklist" do
    it "is shown to a brand-new user (no address, no cards)" do
      user = create(:user, address: nil)
      sign_in user

      get root_path
      expect(response.body).to include("Bien démarrer")
    end

    it "is hidden once all steps are done" do
      user = create(:user, address: "Lyon")
      card_version = create(:card_version)
      create(:user_card, user: user, card_version: card_version)
      create(:user_wanted_card, user: user)
      sign_in user

      get root_path
      expect(response.body).not_to include("Bien démarrer")
    end
  end
end
