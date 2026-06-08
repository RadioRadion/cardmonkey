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
      content { "Proposition d'échange" }
      metadata { { 'type' => 'trade', 'trade_id' => '123' } }
    end
  end
end
