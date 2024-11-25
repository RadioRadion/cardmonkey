FactoryBot.define do
  factory :trade_user_card do
    association :trade
    association :user_card

    trait :with_complete_trade do
      association :trade, factory: [:trade, :with_cards]
    end

    trait :with_accepted_trade do
      association :trade, factory: [:trade, :accepted]
    end

    trait :with_done_trade do
      association :trade, factory: [:trade, :done]
    end
  end
end
