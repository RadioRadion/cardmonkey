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
      border_color: card_data['border_color'],
      frame: card_data['frame'],
      collector_number: card_data['collector_number'],
      rarity: card_data['rarity']
      # Assure-toi d'ajouter ici toute autre mise à jour nécessaire
    )
  end
end

puts "Card versions have been updated."
