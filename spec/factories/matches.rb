FactoryBot.define do
  factory :match do
    association :user_card
    association :user_wanted_card
    association :user
    association :user_id_target, factory: :user

    trait :perfect_match do
      after(:build) do |match|
        card = create(:card)
        card_version = create(:card_version, card: card)
        
        match.user_card = create(:user_card,
          card_version: card_version,
          condition: 'mint',
          language: 'français',
          user: match.user
        )
        
        match.user_wanted_card = create(:user_wanted_card,
          card: card,
          min_condition: 'near_mint',
          language: 'français',
          user: match.user_id_target
        )
      end
    end

    trait :condition_match do
      after(:build) do |match|
        card = create(:card)
        card_version = create(:card_version, card: card)
        
        match.user_card = create(:user_card,
          card_version: card_version,
          condition: 'excellent',
          user: match.user
        )
        
        match.user_wanted_card = create(:user_wanted_card,
          card: card,
          min_condition: 'good',
          user: match.user_id_target
        )
      end
    end

    trait :language_match do
      after(:build) do |match|
        card = create(:card)
        card_version = create(:card_version, card: card)
        
        match.user_card = create(:user_card,
          card_version: card_version,
          language: 'anglais',
          user: match.user
        )
        
        match.user_wanted_card = create(:user_wanted_card,
          card: card,
          language: 'anglais',
          user: match.user_id_target
        )
      end
    end

    trait :flexible_match do
      after(:build) do |match|
        card = create(:card)
        card_version = create(:card_version, card: card)
        
        match.user_card = create(:user_card,
          card_version: card_version,
          condition: 'played',
          language: 'allemand',
          user: match.user
        )
        
        match.user_wanted_card = create(:user_wanted_card,
          card: card,
          min_condition: 'unimportant',
          language: 'dont_care',
          user: match.user_id_target
        )
      end
    end

    trait :specific_version_match do
      after(:build) do |match|
        card = create(:card)
        card_version = create(:card_version, card: card)
        
        match.user_card = create(:user_card,
          card_version: card_version,
          user: match.user
        )
        
        match.user_wanted_card = create(:user_wanted_card,
          card: card,
          card_version: card_version,
          user: match.user_id_target
        )
      end
    end

    trait :with_notification do
      after(:create) do |match|
        create(:notification, 
          user: match.user_id_target,
          notifiable: match
        )
      end
    end
  end
end
