FactoryBot.define do
  factory :notification do
    association :user
    sequence(:content) { |n| "Notification content #{n}" }
    status { :unread }
    notification_type { nil }
    read_at { nil }

    trait :read do
      status { :read }
      read_at { Time.current }
    end

    trait :unread do
      status { :unread }
      read_at { nil }
    end

    trait :trade_notification do
      notification_type { 'trade' }
      content { 'Nouveau trade proposé !' }
    end

    trait :message_notification do
      notification_type { 'message' }
      sequence(:content) { |n| "New message #{n}" }
    end

    trait :old do
      created_at { 2.weeks.ago }
    end

    trait :recent do
      created_at { 1.hour.ago }
    end
  end
end
