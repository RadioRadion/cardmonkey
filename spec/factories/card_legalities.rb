FactoryBot.define do
  factory :card_legality do
    association :card
    sequence(:format) { |n| "format_#{n}" }
    status { 'legal' }

    trait :legal do
      status { 'legal' }
    end

    trait :not_legal do
      status { 'not_legal' }
    end

    trait :restricted do
      status { 'restricted' }
    end

    trait :banned do
      status { 'banned' }
    end

    trait :standard do
      format { 'standard' }
    end

    trait :modern do
      format { 'modern' }
    end

    trait :legacy do
      format { 'legacy' }
    end

    trait :vintage do
      format { 'vintage' }
    end

    trait :commander do
      format { 'commander' }
    end
  end
end
