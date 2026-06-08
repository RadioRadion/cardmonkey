require "rails_helper"

RSpec.describe "Collection import", type: :request do
  let(:user) { create(:user) }
  let(:extension) { create(:extension, code: "LEA") }
  let!(:card) { create(:card, name_en: "Black Lotus", name_fr: "Lotus Noir") }
  let!(:version) { create(:card_version, card: card, extension: extension, scryfall_id: "sf-lotus") }

  before { sign_in user }

  it "shows the import screen" do
    get import_user_user_cards_path(user)
    expect(response).to have_http_status(:ok)
  end

  it "imports a pasted decklist (small = synchronous)" do
    expect do
      post import_run_user_user_cards_path(user),
           params: { source: "decklist", decklist: "1 Black Lotus", default_condition: "near_mint", default_language: "en" }
    end.to change { user.user_cards.count }.by(1)

    expect(response).to have_http_status(:ok)
    expect(user.user_cards.first.card_version).to eq(version)
  end

  it "imports a CSV file by Scryfall ID" do
    file = Rack::Test::UploadedFile.new(
      StringIO.new("Name,Scryfall ID,Quantity\nBlack Lotus,sf-lotus,3\n"), "text/csv", original_filename: "col.csv"
    )

    expect do
      post import_run_user_user_cards_path(user), params: { source: "csv", file: file }
    end.to change { user.user_cards.count }.by(1)

    expect(user.user_cards.first.quantity).to eq(3)
  end

  it "rejects an empty submission" do
    post import_run_user_user_cards_path(user), params: { source: "decklist", decklist: "" }
    expect(response).to redirect_to(import_user_user_cards_path(user))
  end
end
