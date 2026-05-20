FactoryBot.define do
  factory :card do
    sequence(:scryfall_oracle_id) { |n| "oracle-#{n}" }
    sequence(:name_fr) { |n| "Nom de Carte #{n}" }
    sequence(:name_en) { |n| "Card Name #{n}" }
    
    trait :with_versions do
      after(:create) do |card|
        create_list(:card_version, 2, card: card)
      end
    end

    trait :with_wanted_cards do
      after(:create) do |card|
        create_list(:user_wanted_card, 2, card: card)
      end
    end

    trait :with_full_versions do
      after(:create) do |card|
        # Create a version for each rarity with prices
        ['common', 'uncommon', 'rare', 'mythic'].each do |rarity|
          create(:card_version, 
            card: card, 
            rarity: rarity,
            eur_price: case rarity
              when 'common' then 0.02
              when 'uncommon' then 0.10
              when 'rare' then 1.00
              when 'mythic' then 5.00
            end,
            eur_foil_price: case rarity
              when 'common' then 0.10
              when 'uncommon' then 0.50
              when 'rare' then 3.00
              when 'mythic' then 15.00
            end
          )
        end
      end
    end

    trait :with_legalities do
      after(:create) do |card|
        create(:card_legality, :standard, card: card)
        create(:card_legality, :modern, card: card)
      end
    end

    trait :with_full_legalities do
      after(:create) do |card|
        # Create legalities for all major formats
        [
          [:standard, 'legal'],
          [:modern, 'legal'],
          [:legacy, 'legal'],
          [:vintage, 'legal'],
          [:commander, 'legal']
        ].each do |format, status|
          create(:card_legality, format, status: status, card: card)
        end
      end
    end

    trait :banned_in_standard do
      after(:create) do |card|
        create(:card_legality, :standard, status: 'banned', card: card)
      end
    end

    trait :restricted_in_vintage do
      after(:create) do |card|
        create(:card_legality, :vintage, status: 'restricted', card: card)
      end
    end

    trait :complete_card do
      with_full_versions
      with_full_legalities
      with_wanted_cards
    end
  end
end
