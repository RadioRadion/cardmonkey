require 'rails_helper'

RSpec.describe Chatroom, type: :model do
  describe 'associations' do
    it { should have_many(:messages).dependent(:destroy) }
    it { should belong_to(:user) }
    it { should belong_to(:user_invit).class_name('User') }
  end

  describe 'validations' do
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:user_id_invit) }
  end

  describe 'custom validations' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    context 'users_are_different' do
      it 'is valid when users are different' do
        chatroom = build(:chatroom, user: user, user_invit: other_user)
        expect(chatroom).to be_valid
      end

      it 'is invalid when users are the same' do
        chatroom = build(:chatroom, user: user, user_invit: user)
        expect(chatroom).not_to be_valid
        expect(chatroom.errors[:base]).to include("You can't create a chat room with yourself")
      end
    end

    context 'chatroom_uniqueness' do
      let!(:existing_chatroom) { create(:chatroom, user: user, user_invit: other_user) }

      it 'is invalid when a chatroom already exists between users (same order)' do
        chatroom = build(:chatroom, user: user, user_invit: other_user)
        expect(chatroom).not_to be_valid
        expect(chatroom.errors[:base]).to include("A chat room between these users already exists")
      end

      it 'is invalid when a chatroom already exists between users (reverse order)' do
        chatroom = build(:chatroom, user: other_user, user_invit: user)
        expect(chatroom).not_to be_valid
        expect(chatroom.errors[:base]).to include("A chat room between these users already exists")
      end

      it 'allows updating existing chatroom' do
        expect(existing_chatroom.update(updated_at: Time.current)).to be true
      end
    end
  end

  describe 'scopes' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:third_user) { create(:user) }
    
    let!(:chatroom1) { create(:chatroom, user: user, user_invit: other_user) }
    let!(:chatroom2) { create(:chatroom, user: third_user, user_invit: user) }
    let!(:chatroom3) { create(:chatroom, user: other_user, user_invit: third_user) }

    describe '.for_user' do
      it 'returns chatrooms where user is either user or user_invit' do
        chatrooms = Chatroom.for_user(user.id)
        expect(chatrooms).to include(chatroom1, chatroom2)
        expect(chatrooms).not_to include(chatroom3)
      end
    end
  end

  describe '#other_user' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:chatroom) { create(:chatroom, user: user, user_invit: other_user) }

    it 'returns user_invit when current user is user' do
      expect(chatroom.other_user(user)).to eq(other_user)
    end

    it 'returns user when current user is user_invit' do
      expect(chatroom.other_user(other_user)).to eq(user)
    end
  end

  describe '#unread_messages_count' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:chatroom) { create(:chatroom, user: user, user_invit: other_user) }

    before do
      create(:message, chatroom: chatroom, user: user, read_at: nil)
      create(:message, chatroom: chatroom, user: other_user, read_at: nil)
      create(:message, chatroom: chatroom, user: other_user, read_at: Time.current)
    end

    it 'returns count of unread messages for a user' do
      expect(chatroom.unread_messages_count(user)).to eq(1)
      expect(chatroom.unread_messages_count(other_user)).to eq(1)
    end
  end

  describe '#mark_messages_as_read!' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:chatroom) { create(:chatroom, user: user, user_invit: other_user) }
    let!(:unread_message) { create(:message, chatroom: chatroom, user: other_user, read_at: nil) }
    let!(:read_message) { create(:message, chatroom: chatroom, user: other_user, read_at: Time.current) }

    it 'marks all unread messages from other user as read' do
      expect {
        chatroom.mark_messages_as_read!(user)
      }.to change { unread_message.reload.read_at }.from(nil)
      expect(read_message.reload.read_at).not_to be_nil
    end
  end
end
