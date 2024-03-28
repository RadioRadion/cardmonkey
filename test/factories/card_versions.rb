FactoryBot.define do
  factory :card_version do
    card { nil }
    extension { "MyString" }
    scryfall_id { "MyString" }
    img_uri { "MyString" }
    price { "9.99" }
  end
end
