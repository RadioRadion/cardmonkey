FactoryBot.define do
  factory :extension do
    sequence(:name) { |n| "Extension #{n}" }
    sequence(:code) { |n| "EXT#{n}" }
    release_date { Date.current }
    
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
          create_list(:card_version, 2, extension: extension, rarity: rarity)
        end
      end
    end
  end
end
