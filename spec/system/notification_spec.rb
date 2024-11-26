require 'rails_helper'

RSpec.describe "Notifications", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  let(:user) { create(:user) }
  let(:trade) { create(:trade, user: user) }
  
  describe "Gestion des notifications" do
    before do
      login_as(user, scope: :user)
    end

    it "affiche les nouvelles notifications en temps réel", js: true do
      visit root_path
      
      # Vérifie que le compteur de notifications est à 0
      within "#notifications-counter" do
        expect(page).to have_content("0")
      end
      
      # Crée une nouvelle notification via Turbo Streams
      notification = create(:notification, 
        recipient: user,
        notifiable: trade,
        notification_type: 'trade_accepted'
      )
      
      Turbo::StreamsChannel.broadcast_update_to(
        "notifications_for_user_#{user.id}",
        target: "notifications-counter",
        content: "1"
      )
      
      # Vérifie que le compteur est mis à jour sans rechargement
      within "#notifications-counter" do
        expect(page).to have_content("1")
      end
      
      # Ouvre le menu des notifications
      find("#notifications-menu-button").click
      
      # Vérifie le contenu de la notification
      within "#notifications-list" do
        expect(page).to have_content("Votre échange a été accepté")
        expect(page).to have_css(".unread")
      end
    end

    it "marque les notifications comme lues lors du clic", js: true do
      # Crée une notification non lue
      notification = create(:notification, 
        recipient: user,
        notifiable: trade,
        notification_type: 'trade_accepted',
        read_at: nil
      )
      
      visit root_path
      find("#notifications-menu-button").click
      
      # Clique sur la notification
      within "#notifications-list" do
        find("[data-notification-id='#{notification.id}']").click
      end
      
      # Vérifie que la notification est marquée comme lue
      expect(notification.reload.read_at).to be_present
      
      # Vérifie la redirection vers l'objet lié (trade dans ce cas)
      expect(page).to have_current_path(trade_path(trade))
    end
  end
end
