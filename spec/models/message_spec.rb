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

  describe 'scopes' do
    describe '.unread' do
      it 'returns only unread messages' do
        chatroom = create(:chatroom)
        unread_message = create(:message, chatroom: chatroom)
        read_message = create(:message, chatroom: chatroom)
        read_message.update_column(:read_at, Time.current)

        expect(Message.unread).to include(unread_message)
        expect(Message.unread).not_to include(read_message)
      end
    end
  end

  describe '#timestamp' do
    let(:message) { create(:message, created_at: Time.zone.parse('2024-01-24 14:30:00')) }

    it 'returns a formatted timestamp for past days' do
      expect(message.timestamp).to eq('24/01/2024 14:30')
    end
  end

  # Trade messages are identified via `metadata`, not free-text content.
  describe '#trade_message?' do
    it 'returns true when metadata marks it as a trade message' do
      message = build(:message, :trade_message)
      expect(message.trade_message?).to be true
    end

    it 'returns false for a regular message' do
      message = build(:message)
      expect(message.trade_message?).to be false
    end
  end

  describe '#trade_id' do
    context 'when message is a trade message' do
      let(:message) { build(:message, :trade_message) }

      it 'returns the trade id from metadata' do
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

      it 'returns a humanized trade message' do
        expect(message.display_content).to eq("#{message.user.username} a proposé un échange")
      end
    end

    context 'when message is a regular message' do
      let(:message) { build(:message, content: 'Hello') }

      it 'returns the original content' do
        expect(message.display_content).to eq('Hello')
      end
    end
  end
end
