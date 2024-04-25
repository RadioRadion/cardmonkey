FactoryBot.define do
    factory :card_version do
      association :card
      association :extension
      scryfall_id { "scryid#{rand(1000)}" }
      img_uri { "http://example.com/img#{rand(1000)}.jpg" }
      eur_price { rand * 100 }
      border_color { "black" }
      frame { "1993" }
      collector_number { "123" }
      rarity { "rare" }
      eur_foil_price { rand * 100 }
    end
  end
  