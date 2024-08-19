FactoryBot.define do
  factory :user_wanted_card do
    association :user
    association :card
    association :card_version
    min_condition { UserWantedCard.min_conditions.keys.sample }
    language { UserWantedCard.languages.keys.sample }
    foil { [true, false].sample }
    quantity { rand(1..10) }
  end
end
