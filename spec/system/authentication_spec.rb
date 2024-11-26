require 'rails_helper'

RSpec.describe "Authentication", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  let(:user) { create(:user, email: "user@example.com", password: "password123") }

  describe "Inscription" do
    it "permet à un nouvel utilisateur de s'inscrire", js: true do
      visit new_user_registration_path

      within "#new_user" do
        fill_in "Email", with: "nouveau@example.com"
        fill_in "Mot de passe", with: "password123"
        fill_in "Confirmation du mot de passe", with: "password123"
        fill_in "Nom d'utilisateur", with: "NouvelUtilisateur"
        
        click_button "S'inscrire"
      end

      # Vérifie la redirection et le message de succès
      expect(page).to have_current_path(root_path)
      expect(page).to have_content("Bienvenue")
      
      # Vérifie que l'utilisateur est connecté
      within "nav" do
        expect(page).to have_content("NouvelUtilisateur")
      end
    end

    it "affiche les erreurs de validation", js: true do
      visit new_user_registration_path

      within "#new_user" do
        # Soumet le formulaire sans remplir les champs
        click_button "S'inscrire"
      end

      # Vérifie les messages d'erreur
      expect(page).to have_content("Email ne peut pas être vide")
      expect(page).to have_content("Mot de passe ne peut pas être vide")
    end
  end

  describe "Connexion" do
    it "permet à un utilisateur de se connecter", js: true do
      visit new_user_session_path

      within "#new_user" do
        fill_in "Email", with: user.email
        fill_in "Mot de passe", with: "password123"
        click_button "Se connecter"
      end

      # Vérifie la redirection et le message de succès
      expect(page).to have_current_path(root_path)
      expect(page).to have_content("Connecté")
    end

    it "affiche une erreur pour des identifiants invalides", js: true do
      visit new_user_session_path

      within "#new_user" do
        fill_in "Email", with: user.email
        fill_in "Mot de passe", with: "mauvais_mot_de_passe"
        click_button "Se connecter"
      end

      expect(page).to have_content("Email ou mot de passe incorrect")
    end
  end

  describe "Profil utilisateur", js: true do
    before do
      login_as(user)
    end

    it "permet de mettre à jour le profil" do
      visit edit_user_registration_path

      within "#edit_user" do
        fill_in "Nom d'utilisateur", with: "NouveauPseudo"
        fill_in "Mot de passe actuel", with: "password123"
        
        click_button "Mettre à jour"
      end

      # Vérifie la mise à jour
      expect(page).to have_content("Votre compte a été modifié avec succès")
      
      # Vérifie que le changement est reflété dans la navbar
      within "nav" do
        expect(page).to have_content("NouveauPseudo")
      end
    end

    it "permet de mettre à jour les préférences de trading" do
      visit user_path(user)

      within "#trading-preferences" do
        # Met à jour les préférences
        check "Accepte les échanges en personne"
        fill_in "Rayon de déplacement", with: "50"
        
        # La mise à jour devrait être en temps réel avec Turbo
        expect(page).to have_content("Préférences mises à jour")
      end

      # Recharge la page pour vérifier la persistance
      visit user_path(user)
      within "#trading-preferences" do
        expect(page).to have_checked_field("Accepte les échanges en personne")
        expect(page).to have_field("Rayon de déplacement", with: "50")
      end
    end
  end

  describe "Déconnexion" do
    before do
      login_as(user)
    end

    it "permet à un utilisateur de se déconnecter", js: true do
      visit root_path

      within "nav" do
        click_button "Se déconnecter"
      end

      # Vérifie la déconnexion
      expect(page).to have_content("Déconnecté")
      expect(page).to have_link("Se connecter")
    end
  end
end
