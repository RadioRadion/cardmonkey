require 'json'
require_relative '../../config/environment'

# Chemin d'accès au fichier JSON
json_file_path = Rails.root.join('tmp', 'scryfall', 'all-cards.json')

# Lecture et parsing du fichier JSON
file = File.read(json_file_path)
cards_data = JSON.parse(file)

cards_data.each do |card_data|
  # Recherche de la version de la carte existante par scryfall_id
  card_version = CardVersion.find_by(scryfall_id: card_data['id'])
  
  # Si une CardVersion est trouvée, mise à jour des champs spécifiés
  if card_version
    card_version.update(
      eur_foil_price: card_data.dig('prices', 'eur_foil'),  # Mise à jour du prix foil en euros
    )
  end
end

puts "#{CardVersion.where.not(eur_foil_price: nil).count} card versions with foil prices and #{CardVersion.count} total card versions have been updated."
