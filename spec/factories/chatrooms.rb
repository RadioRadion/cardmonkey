FactoryBot.define do
  factory :chatroom do
    association :user
    association :user_invit, factory: :user
    sequence(:name) { |n| "Chat #{n}" }

    trait :with_messages do
      after(:create) do |chatroom|
        create_list(:message, 3, chatroom: chatroom, user: chatroom.user)
        create_list(:message, 2, chatroom: chatroom, user: chatroom.user_invit)
      end
    end
  end
end
