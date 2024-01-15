# spec/models/match_spec.rb

require 'rails_helper'

RSpec.describe Match, type: :model do
  context 'validations' do
    it { should validate_presence_of(:user_id_target) }
  end

  context 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:user_card) }
    it { should belong_to(:user_wanted_card) }
  end
end
