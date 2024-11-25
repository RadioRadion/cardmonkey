require 'rails_helper'

RSpec.describe Message, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:chatroom) }
  end

  describe 'validations' do
    it { should validate_presence_of(:content) }
    it { should_not allow_value('').for(:content) }
  end

  describe 'callbacks' do
    describe '#create_notification' do
      let(:chatroom) { create(:chatroom) }
      let(:message) { build(:message, chatroom: chatroom) }

      it 'creates a notification after message creation' do
        expect { message.save }.to change(Notification, :count).by(1)
      end

      it 'does not create a notification if chatroom is nil' do
        message.chatroom = nil
        expect { message.save }.not_to change(Notification, :count)
      end
    end
  end

  describe 'scopes' do
    describe '.unread' do
      let!(:read_message) { create(:message, :read) }
      let!(:unread_message) { create(:message, :unread) }

      it 'returns only unread messages' do
        expect(Message.unread).to include(unread_message)
        expect(Message.unread).not_to include(read_message)
      end
    end
  end

  describe '#timestamp' do
    let(:message) { create(:message, created_at: Time.zone.parse('2024-01-24 14:30:00')) }

    it 'returns formatted timestamp' do
      expect(message.timestamp).to eq('14:30 24-01-2024')
    end
  end

  describe '#trade_message?' do
    it 'returns true when content contains trade_id' do
      message = build(:message, :trade_message)
      expect(message.trade_message?).to be true
    end

    it 'returns false when content does not contain trade_id' do
      message = build(:message)
      expect(message.trade_message?).to be false
    end
  end

  describe '#trade_id' do
    context 'when message is a trade message' do
      let(:message) { build(:message, content: 'trade_id:123') }

      it 'returns the trade id' do
        expect(message.trade_id).to eq('123')
      end
    end

    context 'when message is not a trade message' do
      let(:message) { build(:message) }

      it 'returns nil' do
        expect(message.trade_id).to be_nil
      end
    end
  end

  describe '#display_content' do
    context 'when message is a trade message' do
      let(:message) { build(:message, :trade_message) }

      it 'returns trade message text' do
        expect(message.display_content).to eq('Nouveau trade proposé !')
      end
    end

    context 'when message is a regular message' do
      let(:message) { build(:message, content: 'Hello') }

      it 'returns original content' do
        expect(message.display_content).to eq('Hello')
      end
    end
  end
end
