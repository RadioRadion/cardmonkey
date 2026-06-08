require "rails_helper"

RSpec.describe "Matches index", type: :request do
  it "presents give/receive lists with distance and reputation per partner" do
    me = create(:user, address: "Lyon", latitude: 45.75, longitude: 4.85)
    partner = create(:user, username: "TradeBuddy", latitude: 45.76, longitude: 4.86)

    # I own a card the partner wants -> I can GIVE
    my_card = create(:user_card, user: me)
    partner_want = create(:user_wanted_card, user: partner)
    create(:match, user_card: my_card, user_wanted_card: partner_want, user_id: me.id, user_id_target: partner.id)

    # The partner owns a card I want -> I can RECEIVE
    partner_card = create(:user_card, user: partner)
    my_want = create(:user_wanted_card, user: me)
    create(:match, user_card: partner_card, user_wanted_card: my_want, user_id: partner.id, user_id_target: me.id)

    sign_in me
    get matches_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("TradeBuddy")
    expect(response.body).to include("Vous pouvez donner")
    expect(response.body).to include("Vous pouvez recevoir")
    expect(response.body).to include("km")
  end

  it "shows an empty state when there are no matches" do
    sign_in create(:user)
    get matches_path
    expect(response.body).to include("Aucune correspondance")
  end
end
