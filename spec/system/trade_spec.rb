require 'rails_helper'

RSpec.describe "Trades", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:card) { create(:card, name: "Black Lotus") }
  let!(:user_card) { create(:user_card, user: user1, card: card, quantity: 1) }
  
  describe "Création d'un échange" do
    before do
      login_as(user1, scope: :user)
    end

    it "permet de créer une proposition d'échange", js: true do
      visit new_trade_path
      
      # Vérifie que la page de création d'échange est chargée
      expect(page).to have_content("Nouvelle proposition d'échange")
      
      # Sélectionne une carte à échanger via Stimulus
      within "#card-selection" do
        find("[data-card-id='#{card.id}']").click
      end
      
      # Vérifie que la carte est ajoutée à la sélection (mise à jour Turbo)
      within "#selected-cards" do
        expect(page).to have_content("Black Lotus")
        expect(page).to have_content("Quantité: 1")
      end
      
      # Remplit les détails de l'échange
      fill_in "trade[description]", with: "Je propose un échange"
      
      # Soumet le formulaire
      click_button "Proposer l'échange"
      
      # Vérifie la redirection et le message de succès
      expect(page).to have_current_path(trade_path(Trade.last))
      expect(page).to have_content("Proposition d'échange créée avec succès")
    end
  end

  describe "Acceptation d'un échange" do
    let!(:trade) { create(:trade, user: user1) }
    let!(:trade_card) { create(:trade_user_card, trade: trade, user_card: user_card) }

    before do
      login_as(user2, scope: :user)
    end

    it "permet d'accepter une proposition d'échange", js: true do
      visit trade_path(trade)
      
      # Vérifie les détails de l'échange
      expect(page).to have_content("Black Lotus")
      
      # Accepte l'échange
      click_button "Accepter l'échange"
      
      # Vérifie la mise à jour du statut (via Turbo Stream)
      expect(page).to have_content("Échange accepté")
      
      # Vérifie la création automatique d'une chatroom
      expect(page).to have_link("Discuter des détails")
    end
  end
end
