FactoryBot.define do
    factory :user_wanted_card do
      association :user
      association :card
      min_condition { :poor}
      foil { [true, false].sample }
      language { :français }
      quantity { Faker::Number.between(from: 1, to: 10) }
    end
  end
  