RSpec.describe Extension, type: :model do
  describe 'validations' do
    subject { FactoryBot.build(:extension) }

    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'is not valid without a code' do
      subject.code = nil
      expect(subject).not_to be_valid
    end

    it 'is not valid without a name' do
      subject.name = nil
      expect(subject).not_to be_valid
    end

    it 'is not valid without a release date' do
      subject.release_date = nil
      expect(subject).not_to be_valid
    end

    it 'is not valid without an icon_uri' do
      subject.icon_uri = nil
      expect(subject).not_to be_valid
    end
  end

  describe 'associations' do
    it { should have_many(:card_versions) }
  end
end
