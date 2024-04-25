RSpec.describe UserWantedCard, type: :model do
    describe 'validations' do
      subject { FactoryBot.build(:user_wanted_card) }
  
      it 'is valid with valid attributes' do
        expect(subject).to be_valid
      end
  
      it 'is not valid without a quantity' do
        subject.quantity = nil
        expect(subject).not_to be_valid
      end
  
      it 'is not valid without a minimum condition' do
        subject.min_condition = nil
        expect(subject).not_to be_valid
      end
  
      it 'is not valid without a language' do
        subject.language = nil
        expect(subject).not_to be_valid
      end
  
      it 'is not valid without specifying foil' do
        subject.foil = nil
        expect(subject).not_to be_valid
      end
    end
  
    describe 'associations' do
      it { should belong_to(:user) }
      it { should belong_to(:card) }
      it { should belong_to(:card_version).optional }
      it { should have_many(:matches) }
    end
  end
  