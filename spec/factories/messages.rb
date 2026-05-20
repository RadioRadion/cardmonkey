FactoryBot.define do
  factory :message do
    association :user
    association :chatroom
    sequence(:content) { |n| "Message content #{n}" }

    trait :read do
      read_at { Time.current }
    end

    trait :unread do
      read_at { nil }
    end

    trait :trade_message do
      sequence(:content) { |n| "trade_id:#{n}" }
    end
  end
end
