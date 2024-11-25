require 'rails_helper'

RSpec.describe Notification, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:content) }
    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:status).in_array(%w[unread read]) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(unread: 'unread', read: 'read').backed_by_column_of_type(:string) }
  end

  describe 'scopes' do
    let!(:user) { create(:user) }
    let!(:unread_notification) { create(:notification, :unread, user: user) }
    let!(:read_notification) { create(:notification, :read, user: user) }
    let!(:old_notification) { create(:notification, :old, user: user) }
    let!(:recent_notification) { create(:notification, :recent, user: user) }

    describe '.unread' do
      it 'returns only unread notifications' do
        expect(described_class.unread).to include(unread_notification)
        expect(described_class.unread).not_to include(read_notification)
      end
    end

    describe '.read' do
      it 'returns only read notifications' do
        expect(described_class.read).to include(read_notification)
        expect(described_class.read).not_to include(unread_notification)
      end
    end

    describe '.recent' do
      it 'returns notifications ordered by creation date desc and limited to 5' do
        6.times { create(:notification, user: user) }
        expect(described_class.recent.count).to eq(5)
        expect(described_class.recent.first.created_at).to be > described_class.recent.last.created_at
      end
    end

    describe '.today' do
      it 'returns notifications from today' do
        today_notification = create(:notification, user: user, created_at: Time.current)
        expect(described_class.today).to include(today_notification)
        expect(described_class.today).not_to include(old_notification)
      end
    end

    describe '.this_week' do
      it 'returns notifications from this week' do
        this_week_notification = create(:notification, user: user, created_at: 2.days.ago)
        expect(described_class.this_week).to include(this_week_notification)
        expect(described_class.this_week).not_to include(old_notification)
      end
    end

    describe '.by_type' do
      let!(:trade_notification) { create(:notification, :trade_notification, user: user) }
      let!(:message_notification) { create(:notification, :message_notification, user: user) }

      it 'returns notifications filtered by type' do
        expect(described_class.by_type('trade')).to include(trade_notification)
        expect(described_class.by_type('trade')).not_to include(message_notification)
      end
    end
  end

  describe 'class methods' do
    describe '.create_notification' do
      let(:user) { create(:user) }

      it 'creates a new notification' do
        expect {
          described_class.create_notification(user.id, "Test message", "test")
        }.to change(Notification, :count).by(1)
      end

      it 'sets the correct attributes' do
        notification = described_class.create_notification(user.id, "Test message", "test")
        expect(notification).to have_attributes(
          user_id: user.id,
          content: "Test message",
          status: "unread",
          notification_type: "test"
        )
      end

      it 'returns nil when creation fails' do
        result = described_class.create_notification(nil, nil)
        expect(result).to be_nil
      end
    end

    describe '.mark_all_as_read' do
      let(:user) { create(:user) }
      let!(:notifications) { create_list(:notification, 3, :unread, user: user) }

      it 'marks all unread notifications as read for a user' do
        expect {
          described_class.mark_all_as_read(user.id)
        }.to change { user.notifications.unread.count }.from(3).to(0)
      end

      it 'sets read_at timestamp' do
        described_class.mark_all_as_read(user.id)
        user.notifications.each do |notification|
          expect(notification.read_at).not_to be_nil
        end
      end
    end
  end

  describe 'instance methods' do
    let(:notification) { create(:notification, :unread) }

    describe '#mark_as_read!' do
      it 'marks notification as read' do
        expect {
          notification.mark_as_read!
        }.to change { notification.status }.from('unread').to('read')
      end

      it 'sets read_at timestamp' do
        expect {
          notification.mark_as_read!
        }.to change { notification.read_at }.from(nil)
      end

      it 'does nothing if notification is already read' do
        read_notification = create(:notification, :read)
        expect {
          read_notification.mark_as_read!
        }.not_to change { read_notification.updated_at }
      end
    end

    describe '#read?' do
      it 'returns true when status is read' do
        notification.status = :read
        expect(notification.read?).to be true
      end

      it 'returns false when status is unread' do
        notification.status = :unread
        expect(notification.read?).to be false
      end
    end

    describe '#unread?' do
      it 'returns true when status is unread' do
        notification.status = :unread
        expect(notification.unread?).to be true
      end

      it 'returns false when status is read' do
        notification.status = :read
        expect(notification.unread?).to be false
      end
    end
  end

  describe 'broadcasting' do
    let(:notification) { build(:notification) }

    it 'broadcasts on create' do
      expect(notification).to receive(:broadcast_notification)
      notification.save
    end

    it 'broadcasts on update' do
      notification.save
      expect(notification).to receive(:broadcast_update)
      notification.update(status: :read)
    end
  end
end
