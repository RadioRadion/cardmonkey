FactoryBot.define do
  factory :card_version do
    association :card, strategy: :create
    association :extension, strategy: :create
    
    sequence(:scryfall_id) { |n| "scryfall-#{n}" }
    sequence(:collector_number) { |n| n.to_s }
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

    trait :with_prices do
      eur_price { 1.0 }
      eur_foil_price { 2.0 }
    end
  end
end
