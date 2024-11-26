require 'rails_helper'

RSpec.describe "CardSearch", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  let(:user) { create(:user) }
  let!(:card1) { create(:card, name: "Black Lotus", extension: create(:extension, name: "Alpha")) }
  let!(:card2) { create(:card, name: "Black Knight", extension: create(:extension, name: "Beta")) }
  
  describe "Recherche de cartes" do
    before do
      login_as(user)
    end

    it "filtre les cartes en temps réel avec Stimulus", js: true do
      visit cards_path
      
      # Test de la recherche en direct
      within "[data-controller='search-filter']" do
        # Tape dans le champ de recherche
        fill_in "search", with: "Black"
        
        # Vérifie que les deux cartes sont affichées
        expect(page).to have_content("Black Lotus")
        expect(page).to have_content("Black Knight")
        
        # Affine la recherche
        fill_in "search", with: "Black L"
        
        # Vérifie que seul Black Lotus reste
        expect(page).to have_content("Black Lotus")
        expect(page).not_to have_content("Black Knight")
      end
    end

    it "filtre par extension avec mise à jour Turbo", js: true do
      visit cards_path
      
      within "#extension-filter" do
        # Sélectionne l'extension Alpha
        select "Alpha", from: "extension"
      end
      
      # Vérifie que seules les cartes de l'extension sélectionnée sont affichées
      expect(page).to have_content("Black Lotus")
      expect(page).not_to have_content("Black Knight")
      
      # Vérifie que l'URL a été mise à jour sans rechargement
      expect(page).to have_current_path(/extension=Alpha/, url: true)
    end

    it "combine les filtres de recherche et d'extension", js: true do
      visit cards_path
      
      # Applique les deux filtres
      within "[data-controller='search-filter']" do
        fill_in "search", with: "Black"
      end
      
      within "#extension-filter" do
        select "Beta", from: "extension"
      end
      
      # Vérifie le résultat combiné
      expect(page).not_to have_content("Black Lotus")
      expect(page).to have_content("Black Knight")
    end

    it "affiche un message quand aucun résultat n'est trouvé", js: true do
      visit cards_path
      
      within "[data-controller='search-filter']" do
        fill_in "search", with: "Carte Inexistante"
      end
      
      # Vérifie le message "Aucun résultat"
      expect(page).to have_content("Aucune carte trouvée")
    end
  end

  describe "Autocomplétion", js: true do
    before do
      login_as(user)
    end

    it "suggère des cartes pendant la frappe" do
      visit new_user_card_path
      
      within "[data-controller='autocomplete']" do
        # Commence à taper
        find(".autocomplete-input").fill_in with: "Bla"
        
        # Vérifie que les suggestions apparaissent
        within ".autocomplete-results" do
          expect(page).to have_content("Black Lotus")
          expect(page).to have_content("Black Knight")
        end
        
        # Continue la frappe
        find(".autocomplete-input").fill_in with: "Black L"
        
        # Vérifie que les suggestions sont filtrées
        within ".autocomplete-results" do
          expect(page).to have_content("Black Lotus")
          expect(page).not_to have_content("Black Knight")
        end
        
        # Sélectionne une suggestion
        find(".autocomplete-result", text: "Black Lotus").click
        
        # Vérifie que la sélection est appliquée
        expect(find(".autocomplete-input").value).to eq "Black Lotus"
      end
    end
  end
end
