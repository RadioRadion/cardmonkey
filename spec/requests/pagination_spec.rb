require "rails_helper"

# Smoke tests for pagy 9 (items -> limit, size array -> integer).
RSpec.describe "Pagination (pagy 9)", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  it "renders the collection index with more than one page" do
    create_list(:user_card, 20, user: user)
    get user_user_cards_path(user)
    expect(response).to have_http_status(:ok)
  end

  it "renders the wanted cards index" do
    create_list(:user_wanted_card, 18, user: user)
    get user_user_wanted_cards_path(user)
    expect(response).to have_http_status(:ok)
  end
end
