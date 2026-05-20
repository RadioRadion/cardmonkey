FactoryBot.define do
  factory :user_wanted_card do
    association :user
    association :card
    card_version { nil }
    quantity { 1 }
    min_condition { 'good' }
    language { 'fr' }
    foil { false }

    trait :any_condition do
      min_condition { 'unimportant' }
    end

    trait :any_language do
      language { 'any' }
    end

    trait :foil_only do
      foil { true }
    end

    trait :with_matches do
      after(:create) do |wanted_card|
        other_user = create(:user)
        card_version = create(:card_version, card: wanted_card.card)
        user_card = create(:user_card,
          user: other_user,
          card_version: card_version,
          language: wanted_card.language,
          condition: wanted_card.min_condition
        )
        create(:match,
          user_card: user_card,
          user_wanted_card: wanted_card,
          user: other_user,
          user_id_target: wanted_card.user_id
        )
      end
    end

    # Minimum Conditions
    trait :mint_or_better do
      min_condition { 'mint' }
    end

    trait :near_mint_or_better do
      min_condition { 'near_mint' }
    end

    trait :excellent_or_better do
      min_condition { 'excellent' }
    end

    trait :good_or_better do
      min_condition { 'good' }
    end

    trait :light_played_or_better do
      min_condition { 'light_played' }
    end

    trait :played_or_better do
      min_condition { 'played' }
    end

    trait :any_played do
      min_condition { 'poor' }
    end

    # Specific Languages
    trait :french_only do
      language { 'fr' }
    end

    trait :english_only do
      language { 'en' }
    end

    trait :german_only do
      language { 'de' }
    end

    trait :italian_only do
      language { 'it' }
    end

    trait :japanese_only do
      language { 'ja' }
    end

    trait :russian_only do
      language { 'ru' }
    end

    # Multiple copies
    trait :playset do
      quantity { 4 }
    end

    # Common search combinations
    trait :collector_search do
      mint_or_better
      foil_only
      japanese_only
    end

    trait :player_search do
      good_or_better
      english_only
      playset
    end

    trait :flexible_search do
      any_condition
      any_language
      quantity { 1 }
    end

    # Version specific search
    trait :specific_version do
      after(:build) do |wanted_card|
        wanted_card.card_version ||= create(:card_version, card: wanted_card.card)
      end
    end

    trait :any_version do
      card_version { nil }
    end
  end
end
