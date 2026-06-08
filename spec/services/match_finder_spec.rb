require 'rails_helper'

RSpec.describe MatchFinder do
  let(:card) { create(:card) }
  let(:card_version) { create(:card_version, card: card) }
  let(:owner)  { create(:user) }
  let(:seeker) { create(:user) }

  describe '.rows_for_user_card' do
    let(:user_card) do
      create(:user_card, user: owner, card_version: card_version, condition: 'near_mint', language: 'fr')
    end

    it 'matches a wanted card of the same card, compatible language and met condition' do
      wanted = create(:user_wanted_card, user: seeker, card: card, min_condition: 'good', language: 'fr')
      ids = MatchFinder.rows_for_user_card(user_card).map { |r| r[:user_wanted_card_id] }
      expect(ids).to include(wanted.id)
    end

    it 'does not match when the owned condition is below the wanted minimum' do
      create(:user_wanted_card, user: seeker, card: card, min_condition: 'mint', language: 'fr')
      expect(MatchFinder.rows_for_user_card(user_card)).to be_empty
    end

    it 'does not match a different language' do
      create(:user_wanted_card, user: seeker, card: card, min_condition: 'good', language: 'en')
      expect(MatchFinder.rows_for_user_card(user_card)).to be_empty
    end

    it "matches when the wanted language is 'any'" do
      wanted = create(:user_wanted_card, user: seeker, card: card, min_condition: 'good', language: 'any')
      ids = MatchFinder.rows_for_user_card(user_card).map { |r| r[:user_wanted_card_id] }
      expect(ids).to include(wanted.id)
    end

    it 'never matches the same user (no self-match)' do
      create(:user_wanted_card, user: owner, card: card, min_condition: 'good', language: 'fr')
      expect(MatchFinder.rows_for_user_card(user_card)).to be_empty
    end
  end

  # The condition filter must be applied symmetrically (the bug this fixes:
  # the UserWantedCard path previously ignored it).
  describe '.rows_for_user_wanted_card' do
    it 'excludes user_cards below the wanted minimum condition' do
      wanted = create(:user_wanted_card, user: seeker, card: card, min_condition: 'mint', language: 'fr')
      create(:user_card, user: owner, card_version: card_version, condition: 'good', language: 'fr')
      expect(MatchFinder.rows_for_user_wanted_card(wanted)).to be_empty
    end

    it 'includes user_cards meeting the wanted minimum condition' do
      wanted = create(:user_wanted_card, user: seeker, card: card, min_condition: 'good', language: 'fr')
      uc = create(:user_card, user: owner, card_version: card_version, condition: 'mint', language: 'fr')
      ids = MatchFinder.rows_for_user_wanted_card(wanted).map { |r| r[:user_card_id] }
      expect(ids).to include(uc.id)
    end
  end

  describe '.create_for_user_card' do
    let(:user_card) do
      create(:user_card, user: owner, card_version: card_version, condition: 'near_mint', language: 'fr')
    end

    it 'persists matches and is idempotent on re-run' do
      create(:user_wanted_card, user: seeker, card: card, min_condition: 'good', language: 'fr')

      expect { MatchFinder.create_for_user_card(user_card) }.to change(Match, :count).by(1)
      expect { MatchFinder.create_for_user_card(user_card) }.not_to change(Match, :count)
    end
  end
end
