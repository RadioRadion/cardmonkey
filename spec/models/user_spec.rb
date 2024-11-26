require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'is not valid without an email' do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
    end

    it 'is not valid with an invalid email format' do
      user = build(:user, email: 'invalid_email')
      expect(user).not_to be_valid
    end

    it 'is not valid with a duplicate email' do
      create(:user, email: 'test@example.com')
      user = build(:user, email: 'test@example.com')
      expect(user).not_to be_valid
    end

    it 'is not valid without a password' do
      user = build(:user, password: nil)
      expect(user).not_to be_valid
    end
  end

  describe 'associations' do
    subject { build(:user) }

    it { should have_many(:sent_chatrooms).class_name('Chatroom') }
    it { should have_many(:received_chatrooms).class_name('Chatroom') }
    it { should have_many(:messages) }
    it { should have_many(:trades) }
    it { should have_many(:user_cards) }
    it { should have_many(:card_versions).through(:user_cards) }
    it { should have_many(:cards).through(:card_versions) }
    it { should have_many(:user_wanted_cards) }
    it { should have_many(:matches) }
    it { should have_many(:notifications) }
    it { should have_one_attached(:avatar) }
  end

  describe 'enums' do
    it { should define_enum_for(:preference).with_values(value_based: 0, quantity_based: 1) }
  end

  describe 'geocoding' do
    it 'geocodes address when address changes' do
      user = create(:user, address: '123 Main St')
      user.address = '456 New St'
      expect(user).to receive(:geocode)
      user.save
    end

    it 'does not geocode when address does not change' do
      user = create(:user, address: '123 Main St')
      user.username = 'New Username'
      expect(user).not_to receive(:geocode)
      user.save
    end
  end

  describe '#chatrooms' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    it 'returns chatrooms where user is sender or receiver' do
      sent_chatroom = create(:chatroom, user: user, user_id_invit: other_user.id)
      third_user = create(:user)
      received_chatroom = create(:chatroom, user: third_user, user_id_invit: user.id)
      unrelated_chatroom = create(:chatroom, user: other_user, user_id_invit: third_user.id)

      chatrooms = user.chatrooms
      expect(chatrooms).to include(sent_chatroom)
      expect(chatrooms).to include(received_chatroom)
      expect(chatrooms).not_to include(unrelated_chatroom)
    end
  end

  describe '#top_matching_users' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    it 'returns users with matches in descending order' do
      user_card = create(:user_card, user: user)
      create_list(:match, 3, user_id: user.id, user_id_target: other_user.id, user_card: user_card)

      top_users = user.top_matching_users(1)
      expect(top_users).to include(other_user)
    end

    it 'limits the number of results' do
      users = create_list(:user, 3)
      user_card = create(:user_card, user: user)
      users.each do |u|
        create(:match, user_id: user.id, user_id_target: u.id, user_card: user_card)
      end

      expect(user.top_matching_users(2).count).to eq(2)
    end
  end

  describe '#matching_cards_with_user' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    it 'returns matching cards between two users' do
      extension = create(:extension)
      card = create(:card)
      card_version = create(:card_version, card: card, extension: extension)
      user_card = create(:user_card, user: user, card_version: card_version)
      create(:match, user_id: user.id, user_id_target: other_user.id, user_card: user_card)
      
      matching_cards = user.matching_cards_with_user(other_user.id)
      expect(matching_cards).to be_present
      expect(matching_cards.first.id).to eq(card.id)
    end
  end

  describe '#all_trades' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    it 'returns trades where user is sender or receiver' do
      sent_trade = create(:trade, user: user, user_id_invit: other_user.id)
      received_trade = create(:trade, user: other_user, user_id_invit: user.id)
      unrelated_trade = create(:trade, user: other_user, user_id_invit: create(:user).id)

      trades = user.all_trades
      expect(trades).to include(sent_trade)
      expect(trades).to include(received_trade)
      expect(trades).not_to include(unrelated_trade)
    end
  end

  describe '#matching_stats' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    it 'returns correct statistics' do
      user_card = create(:user_card, user: user, condition: 'mint', language: 'french')
      create(:match, user_id: user.id, user_id_target: other_user.id, user_card: user_card)

      stats = user.matching_stats
      expect(stats[:total_matches]).to eq(1)
      expect(stats[:unique_matched_users]).to eq(1)
      expect(stats[:matches_by_condition]).to include('mint' => 1)
      expect(stats[:matches_by_language]).to include('french' => 1)
    end
  end

  describe '#avatar_thumbnail' do
    let(:user) { create(:user) }

    context 'when avatar is attached' do
      before do
        user.avatar.attach(
          io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'avatar.jpg')),
          filename: 'avatar.jpg',
          content_type: 'image/jpeg'
        )
      end

      it 'returns the attached avatar' do
        expect(user.avatar_thumbnail).to eq(user.avatar)
      end
    end

    context 'when avatar is not attached' do
      it 'returns a placeholder URL' do
        expect(user.avatar_thumbnail).to eq("https://via.placeholder.com/64")
      end
    end
  end
end
