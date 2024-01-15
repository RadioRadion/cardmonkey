FactoryBot.define do
    factory :user_card do
      association :user
      association :card
      condition { :poor }
      foil { [true, false].sample }
      language { :français }
      quantity { Faker::Number.between(from: 1, to: 10) }
    end
  end
  