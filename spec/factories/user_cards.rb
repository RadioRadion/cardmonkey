FactoryBot.define do
  factory :user_card do
    association :user
    association :card_version
    condition { UserCard.conditions.keys.sample }
    language { UserCard.languages.keys.sample }
    foil { [true, false].sample }
    quantity { rand(1..10) } # Assurez-vous que la quantité est toujours positive et non nulle
  end
end
