require 'rails_helper'

RSpec.describe "UserCards", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  let(:user) { create(:user) }
  let(:card) { create(:card, name: "Black Lotus") }
  
  describe "Gestion des cartes" do
    before do
      login_as(user, scope: :user)
    end

    it "permet d'ajouter une nouvelle carte à sa collection", js: true do
      visit new_user_card_path
      
      # Test de l'autocomplétion
      within ".card-search" do
        # Simule la frappe dans le champ autocomplete
        find("[data-controller='autocomplete']").fill_in with: "Black"
        
        # Attend l'apparition des résultats
        expect(page).to have_content("Black Lotus")
        
        # Sélectionne la carte dans les résultats
        find(".autocomplete-result", text: "Black Lotus").click
      end
      
      # Remplit les détails de la carte
      select "Near Mint", from: "État"
      select "Français", from: "Langue"
      fill_in "Quantité", with: "1"
      
      # Soumet le formulaire
      click_button "Ajouter à ma collection"
      
      # Vérifie la redirection et le message de succès
      expect(page).to have_current_path(user_cards_path)
      expect(page).to have_content("Carte ajoutée à votre collection")
      
      # Vérifie que la carte apparaît dans la liste (mise à jour Turbo)
      within "#user-cards-list" do
        expect(page).to have_content("Black Lotus")
        expect(page).to have_content("Near Mint")
        expect(page).to have_content("Français")
        expect(page).to have_content("1")
      end
    end

    context "avec une carte existante" do
      let!(:user_card) { create(:user_card, user: user, card: card, quantity: 1) }

      it "permet de modifier la quantité via Stimulus", js: true do
        visit user_cards_path
        
        within "[data-controller='card-quantity']" do
          # Trouve le bouton d'augmentation de quantité
          find(".quantity-increase").click
          
          # Vérifie que la quantité est mise à jour sans rechargement
          expect(page).to have_css(".quantity-display", text: "2")
          
          # Vérifie que le changement est persisté
          expect(user_card.reload.quantity).to eq(2)
        end
      end

      it "permet de supprimer une carte avec confirmation", js: true do
        visit user_cards_path
        
        within "#user-card-#{user_card.id}" do
          # Clique sur le bouton de suppression
          accept_confirm do
            click_button "Supprimer"
          end
        end
        
        # Vérifie que la carte est supprimée sans rechargement
        expect(page).not_to have_content("Black Lotus")
        expect(UserCard.exists?(user_card.id)).to be false
      end
    end
  end
end
