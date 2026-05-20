FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:username) { |n| "user#{n}" }
    password { "password123" }
    address { "123 Test Street" }
    area { "Test Area" }
    preference { :value_based }

    trait :with_avatar do
      after(:build) do |user|
        user.avatar.attach(
          io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'avatar.jpg')),
          filename: 'avatar.jpg',
          content_type: 'image/jpeg'
        )
      end
    end

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

    trait :with_trades do
      after(:create) do |user|
        create_list(:trade, 2, user: user)
        create_list(:trade, 2, user_id_invit: user.id)
      end
    end

    trait :with_matches do
      after(:create) do |user|
        other_user = create(:user)
        user_card = create(:user_card, user: user)
        create_list(:match, 3, user_id: user.id, user_id_target: other_user.id, user_card: user_card)
      end
    end
  end
end
