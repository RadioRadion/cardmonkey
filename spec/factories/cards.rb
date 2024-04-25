FactoryBot.define do
  factory :card do
    scryfall_oracle_id { Faker::Alphanumeric.alphanumeric(number: 10) }
    name_en { "Magic Card EN #{Faker::Lorem.word}" }
    name_fr { "Magic Card FR #{Faker::Lorem.word}" }
  end
end
