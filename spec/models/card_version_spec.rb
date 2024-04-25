RSpec.describe CardVersion, type: :model do
    describe 'validations' do
      let(:card) { FactoryBot.create(:card) }
      let(:extension) { FactoryBot.create(:extension) }
  
      subject { FactoryBot.build(:card_version, card: card, extension: extension) }
  
      it 'is valid with valid attributes' do
        expect(subject).to be_valid
      end
  
      it 'is not valid without a card' do
        subject.card = nil
        expect(subject).not_to be_valid
      end
  
      it 'is not valid without an extension' do
        subject.extension = nil
        expect(subject).not_to be_valid
      end
  
      it 'is not valid without a scryfall_id' do
        subject.scryfall_id = nil
        expect(subject).not_to be_valid
      end
  
      it 'is not valid without a rarity' do
        subject.rarity = nil
        expect(subject).not_to be_valid
      end
  
      it 'is not valid without a frame' do
        subject.frame = nil
        expect(subject).not_to be_valid
      end
  
      it 'is not valid without a border_color' do
        subject.border_color = nil
        expect(subject).not_to be_valid
      end
    end
  
    describe 'associations' do
      it { should belong_to(:card) }
      it { should belong_to(:extension) }
      it { should have_many(:user_cards) }
    end
  end
  