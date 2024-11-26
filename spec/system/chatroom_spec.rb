require 'rails_helper'

RSpec.describe "Chatrooms", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:chatroom) { create(:chatroom, user: user1, user_id_invit: user2.id) }
  
  describe "Conversation entre deux utilisateurs" do
    before do
      login_as(user1, scope: :user)
    end

    it "permet d'envoyer et recevoir des messages" do
      # Visite la page de la chatroom
      visit chatroom_path(chatroom)
      
      # Vérifie que la page est chargée correctement
      expect(page).to have_css("#messages")
      
      # Envoie un nouveau message
      fill_in "message_content", with: "Bonjour, je suis intéressé par un échange"
      click_on "Envoyer"
      
      # Vérifie que le message apparaît dans le chat (grâce à Turbo Streams)
      expect(page).to have_content("Bonjour, je suis intéressé par un échange")
      
      # Vérifie que le message est associé au bon utilisateur
      within("#messages") do
        expect(page).to have_content(user1.username)
      end
    end

    it "met à jour la conversation en temps réel", js: true do
      visit chatroom_path(chatroom)
      
      # Simule un nouveau message d'un autre utilisateur via Turbo Streams
      Turbo::StreamsChannel.broadcast_append_to(
        "chatroom_#{chatroom.id}",
        target: "messages",
        partial: "messages/message",
        locals: { message: create(:message, chatroom: chatroom, user: user2) }
      )
      
      # Vérifie que le message apparaît sans rechargement
      expect(page).to have_content(user2.username)
    end
  end
end
