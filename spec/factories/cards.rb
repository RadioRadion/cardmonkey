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
        # Crée une version pour chaque rareté
        ['common', 'uncommon', 'rare', 'mythic'].each do |rarity|
          create(:card_version, card: card, rarity: rarity)
        end
      end
    end
  end
end
