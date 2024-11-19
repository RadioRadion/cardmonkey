FactoryBot.define do
  factory :user_card do
    association :user
    association :card_version
    quantity { 1 }
    condition { 'near_mint' }
    language { 'français' }
    foil { false }

    trait :available do
      available { true }
    end

    trait :unavailable do
      available { false }
    end

    trait :foil do
      foil { true }
    end

    trait :with_matches do
      after(:create) do |user_card|
        create_list(:match, 2, user_card: user_card)
      end
    end

    # Conditions
    trait :mint do
      condition { 'mint' }
    end

    trait :near_mint do
      condition { 'near_mint' }
    end

    trait :excellent do
      condition { 'excellent' }
    end

    trait :good do
      condition { 'good' }
    end

    trait :light_played do
      condition { 'light_played' }
    end

    trait :played do
      condition { 'played' }
    end

    trait :poor do
      condition { 'poor' }
    end

    # Languages
    trait :french do
      language { 'français' }
    end

    trait :english do
      language { 'anglais' }
    end

    trait :german do
      language { 'allemand' }
    end

    trait :italian do
      language { 'italien' }
    end

    trait :japanese do
      language { 'japonais' }
    end

    trait :russian do
      language { 'russe' }
    end

    # Multiple copies
    trait :multiple_copies do
      quantity { 4 }
    end

    # Combinations
    trait :premium do
      foil
      mint
      english
    end

    trait :collector do
      foil
      mint
      japanese
    end

    trait :played_set do
      played
      multiple_copies
    end
  end
end
