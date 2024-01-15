FactoryBot.define do
    factory :user do
      email { Faker::Internet.email }
      password { 'password' }
      password_confirmation { 'password' }
      username { Faker::Internet.username }
      latitude { Faker::Address.latitude }
      longitude { Faker::Address.longitude }
      address { Faker::Address.full_address }
      area { 50 }  # Vous pouvez ajuster cette valeur selon vos besoins
      preference { 'value_based' } # ou 'quantity_based', selon la préférence par défaut
  
      # Les attributs reset_password_token et reset_password_sent_at ne sont généralement pas nécessaires pour les tests de base.
      # Si vous avez besoin de les définir pour certains tests, vous pouvez les surcharger dans les scénarios de test spécifiques.
    end
  end
  