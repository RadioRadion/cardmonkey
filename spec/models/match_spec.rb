require 'rails_helper'

RSpec.describe Match, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:user_card) }
    it { should belong_to(:user_wanted_card) }
  end

  describe 'validations' do
    it { should validate_presence_of(:user_id_target) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      match = build(:match)
      expect(match).to be_valid
    end
  end
end
