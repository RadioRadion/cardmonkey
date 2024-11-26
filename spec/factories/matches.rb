FactoryBot.define do
  factory :match do
    transient do
      target_user { create(:user) }
    end

    after(:build) do |match, evaluator|
      # Create the user_wanted_card first with its user
      match.user_wanted_card ||= create(:user_wanted_card, user: evaluator.target_user)
      
      # Create the user_card with its user
      match.user_card ||= create(:user_card)
      match.user ||= match.user_card.user
      
      # Set the user_id_target from the user_wanted_card's user
      match.user_id_target = match.user_wanted_card.user_id
    end

    trait :perfect_match do
      after(:build) do |match|
        card = create(:card)
        card_version = create(:card_version, card: card)
        
        match.user_card = create(:user_card,
          card_version: card_version,
          condition: 'mint',
          language: 'fr',
          user: match.user
        )
        
        match.user_wanted_card = create(:user_wanted_card,
          card: card,
          min_condition: 'near_mint',
          language: 'fr',
          user: create(:user)
        )
        match.user_id_target = match.user_wanted_card.user_id
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
          user: create(:user)
        )
        match.user_id_target = match.user_wanted_card.user_id
      end
    end

    trait :language_match do
      after(:build) do |match|
        card = create(:card)
        card_version = create(:card_version, card: card)
        
        match.user_card = create(:user_card,
          card_version: card_version,
          language: 'en',
          user: match.user
        )
        
        match.user_wanted_card = create(:user_wanted_card,
          card: card,
          language: 'en',
          user: create(:user)
        )
        match.user_id_target = match.user_wanted_card.user_id
      end
    end

    trait :flexible_match do
      after(:build) do |match|
        card = create(:card)
        card_version = create(:card_version, card: card)
        
        match.user_card = create(:user_card,
          card_version: card_version,
          condition: 'played',
          language: 'de',
          user: match.user
        )
        
        match.user_wanted_card = create(:user_wanted_card,
          card: card,
          min_condition: 'unimportant',
          language: 'any',
          user: create(:user)
        )
        match.user_id_target = match.user_wanted_card.user_id
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
          user: create(:user)
        )
        match.user_id_target = match.user_wanted_card.user_id
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
