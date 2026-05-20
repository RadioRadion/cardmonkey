FactoryBot.define do
  factory :supported_language do
    sequence(:code) { |n| "lang_#{n}" }
    sequence(:name) { |n| "Language #{n}" }
    active { true }

    trait :inactive do
      active { false }
    end

    trait :french do
      code { 'fr' }
      name { 'French' }
    end

    trait :english do
      code { 'en' }
      name { 'English' }
    end

    trait :german do
      code { 'de' }
      name { 'German' }
    end

    trait :italian do
      code { 'it' }
      name { 'Italian' }
    end

    trait :spanish do
      code { 'es' }
      name { 'Spanish' }
    end

    trait :japanese do
      code { 'ja' }
      name { 'Japanese' }
    end
  end
end
