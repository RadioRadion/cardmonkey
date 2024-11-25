FactoryBot.define do
  factory :trade do
    association :user
    association :user_invit, factory: :user
    status { :pending }

    trait :pending do
      status { :pending }
      accepted_at { nil }
      completed_at { nil }
    end

    trait :accepted do
      status { :accepted }
      accepted_at { Time.current }
      completed_at { nil }
    end

    trait :done do
      status { :done }
      accepted_at { 1.day.ago }
      completed_at { Time.current }
    end

    trait :with_cards do
      after(:create) do |trade|
        create_list(:trade_user_card, 2, trade: trade, user_card: create(:user_card, user: trade.user))
        create_list(:trade_user_card, 2, trade: trade, user_card: create(:user_card, user: trade.user_invit))
      end
    end

    trait :with_chatroom do
      after(:create) do |trade|
        create(:chatroom, user: trade.user, user_invit: trade.user_invit)
      end
    end
  end
end