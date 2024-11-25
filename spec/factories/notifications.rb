FactoryBot.define do
  factory :notification do
    association :user
    sequence(:content) { |n| "Notification content #{n}" }
    status { :unread }
    notification_type { nil }

    trait :read do
      status { :read }
    end

    trait :unread do
      status { :unread }
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
      created_at { 1.week.ago }
    end

    trait :recent do
      created_at { 1.hour.ago }
    end
  end
end
