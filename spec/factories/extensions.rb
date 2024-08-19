FactoryBot.define do
  factory :extension do
    sequence(:code) { |n| "EXT#{n}" }  
    name { "Extension Name #{rand(1000)}" }
    release_date { Date.today - rand(100).days }
    icon_uri { "http://example.com/icon#{rand(1000)}.png" }
  end
end
