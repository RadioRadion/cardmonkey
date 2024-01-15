FactoryBot.define do
    factory :card do
      scryfall_oracle_id { Faker::Alphanumeric.alphanumeric(number: 10) }
      img_uri { Faker::Internet.url }
      extension { Faker::Esport.game }
      price { Faker::Commerce.price(range: 0..100.0) }
      img_path { Faker::File.file_name(dir: 'path/to') }
      scryfall_id { Faker::Alphanumeric.alphanumeric(number: 10) }
      name_en { "Card Name EN #{Faker::Lorem.word}" }
    name_fr { "Nom de Carte FR #{Faker::Lorem.word}" }
    end
  end
  