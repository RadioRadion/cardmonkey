require "rails_helper"

RSpec.describe "Trade next action", type: :request do
  let(:alice) { create(:user) }
  let(:bob)   { create(:user) }

  it "tells the invitee it is their turn on a pending trade" do
    trade = create(:trade, user: alice, user_invit: bob, status: :pending)
    sign_in bob

    get trade_path(trade)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("À vous de jouer")
    expect(response.body).to include("Refuser")
  end

  it "tells the initiator they are waiting on a pending trade" do
    trade = create(:trade, user: alice, user_invit: bob, status: :pending)
    sign_in alice

    get trade_path(trade)
    expect(response.body).to include("En attente de la réponse")
  end

  it "prompts the physical confirmation once accepted" do
    trade = create(:trade, user: alice, user_invit: bob, status: :accepted)
    sign_in alice

    get trade_path(trade)
    expect(response.body).to include("Échange accepté")
    expect(response.body).to include("physique")
  end
end
