RSpec.describe UserCard, type: :model do
    describe 'validations' do
      subject { FactoryBot.build(:user_card) }
  
      it 'is valid with valid attributes' do
        expect(subject).to be_valid
      end
  
      it 'is not valid without a quantity' do
        subject.quantity = nil
        expect(subject).not_to be_valid
      end
  
      it 'is not valid without a condition' do
        subject.condition = nil
        expect(subject).not_to be_valid
      end
  
      it 'is not valid without a language' do
        subject.language = nil
        expect(subject).not_to be_valid
      end
  
      it 'is not valid without foil specified' do
        subject.foil = nil
        expect(subject).not_to be_valid
      end
    end
  
    describe 'associations' do
      it { should belong_to(:user) }
      it { should belong_to(:card_version) }
      it { should have_many(:matches) }
    end
  end
  