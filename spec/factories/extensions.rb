FactoryBot.define do
  factory :extension do
    sequence(:name) { |n| "Extension #{n}" }
    sequence(:code) { |n| "EXT#{n}" }
    release_date { Date.current }
    sequence(:icon_uri) { |n| "https://example.com/icons/ext#{n}.png" }
    
    trait :with_cards do
      after(:create) do |extension|
        create_list(:card_version, 3, extension: extension)
      end
    end

    trait :future_release do
      release_date { 1.month.from_now }
    end

    trait :past_release do
      release_date { 1.year.ago }
    end

    trait :with_all_rarities do
      after(:create) do |extension|
        ['common', 'uncommon', 'rare', 'mythic'].each do |rarity|
          create_list(:card_version, 2, 
            extension: extension, 
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

    trait :standard_legal do
      after(:create) do |extension|
        create_list(:card, 3, :with_legalities) do |card|
          create(:card_version, card: card, extension: extension)
        end
      end
    end

    trait :modern_legal do
      release_date { 8.years.ago }
      after(:create) do |extension|
        create_list(:card, 3) do |card|
          create(:card_legality, :modern, card: card)
          create(:card_version, card: card, extension: extension)
        end
      end
    end

    trait :vintage_legal do
      release_date { 20.years.ago }
      after(:create) do |extension|
        create_list(:card, 3) do |card|
          create(:card_legality, :vintage, card: card)
          create(:card_version, card: card, extension: extension)
        end
      end
    end

    trait :complete_extension do
      with_all_rarities
      standard_legal
      after(:create) do |extension|
        # Add some special cards
        create(:card, :banned_in_standard).tap do |card|
          create(:card_version, card: card, extension: extension, rarity: 'mythic')
        end
        create(:card, :restricted_in_vintage).tap do |card|
          create(:card_version, card: card, extension: extension, rarity: 'rare')
        end
      end
    end
  end
end
