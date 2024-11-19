FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:username) { |n| "user#{n}" }
    password { 'password123' }
    password_confirmation { 'password123' }
    
    trait :with_cards do
      after(:create) do |user|
        create_list(:user_card, 3, user: user)
      end
    end

    trait :with_wanted_cards do
      after(:create) do |user|
        create_list(:user_wanted_card, 3, user: user)
      end
    end

    trait :with_matches do
      after(:create) do |user|
        create_list(:match, 2, user: user)
      end
    end

    trait :with_location do
      address { '10 Rue de la Paix, Paris' }
      after(:create, &:geocode)
    end

    trait :value_based do
      preference { :value_based }
    end

    trait :quantity_based do
      preference { :quantity_based }
    end
  end
end
