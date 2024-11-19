FactoryBot.define do
  factory :user_wanted_card do
    association :user
    association :card
    association :card_version, required: false
    quantity { 1 }
    min_condition { 'good' }
    language { 'français' }
    foil { false }

    trait :any_condition do
      min_condition { 'unimportant' }
    end

    trait :any_language do
      language { 'dont_care' }
    end

    trait :foil_only do
      foil { true }
    end

    trait :with_matches do
      after(:create) do |wanted_card|
        create_list(:match, 2, user_wanted_card: wanted_card)
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
      language { 'français' }
    end

    trait :english_only do
      language { 'anglais' }
    end

    trait :german_only do
      language { 'allemand' }
    end

    trait :italian_only do
      language { 'italien' }
    end

    trait :japanese_only do
      language { 'japonais' }
    end

    trait :russian_only do
      language { 'russe' }
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
