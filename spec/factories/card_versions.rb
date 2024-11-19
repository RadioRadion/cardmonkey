FactoryBot.define do
  factory :card_version do
    association :card
    association :extension
    
    sequence(:scryfall_id) { |n| "scryfall-#{n}" }
    rarity { ['common', 'uncommon', 'rare', 'mythic'].sample }
    frame { ['1993', '1997', '2003', '2015', 'future'].sample }
    border_color { ['black', 'white', 'borderless', 'silver', 'gold'].sample }
    
    trait :with_user_cards do
      after(:create) do |card_version|
        create_list(:user_card, 3, card_version: card_version)
      end
    end

    trait :common do
      rarity { 'common' }
    end

    trait :uncommon do
      rarity { 'uncommon' }
    end

    trait :rare do
      rarity { 'rare' }
    end

    trait :mythic do
      rarity { 'mythic' }
    end
  end
end
