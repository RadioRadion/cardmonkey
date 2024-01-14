require 'json'

# Chemin vers le fichier JSON dans tmp/scryfall
json_file_path = Rails.root.join('tmp', 'scryfall', 'all-cards.json')

# Supprimer toutes les cartes existantes
Card.delete_all

# Lire le fichier JSON
file = File.read(json_file_path)
cards_data = JSON.parse(file)

# Compteur pour les cartes
cards_count = 0
puts "ok"
cards_data.each do |card_data|
  #break if cards_count >= 1000

  # Ignorer les cartes qui ne sont ni en anglais ni en français
  next unless ['en', 'fr'].include?(card_data['lang'])

  scryfall_oracle_id = card_data['oracle_id']

  card = Card.find_or_initialize_by(scryfall_oracle_id: scryfall_oracle_id)

  # Mettre à jour les informations communes à toutes les langues
  card.extension = card_data['set_name']
  card.img_uri = card_data['image_uris']&.fetch('normal', nil)
  card.price = card_data['prices']['eur']

  # Mettre à jour le nom en fonction de la langue
  if card_data['lang'] == 'en'
    card.name_en = card_data['name']
  elsif card_data['lang'] == 'fr'
    card.name_fr = card_data['printed_name']
  end

  if card.new_record? || card.changed?
    if card.save
      puts "Carte sauvegardée : #{card.name_en || card.name_fr}"
    else
      puts "Erreur de sauvegarde : #{card.errors.full_messages.join(', ')}"
    end
    #cards_count += 1
  end
rescue => e
  puts "Erreur lors de la création/mise à jour de la carte : #{e.message}"
end

puts "#{Card.count} cartes ont été importées/mises à jour."