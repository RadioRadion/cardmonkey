require 'open-uri'
require 'json'

# Assure-toi que le chemin est correct pour ton environnement
require_relative '../../config/environment'

# URL de l'API Scryfall pour les extensions
url = 'https://api.scryfall.com/sets'

begin
  # Faire une requête GET à l'API Scryfall
  sets_json = URI.open(url).read
  sets_data = JSON.parse(sets_json)

  # Itérer sur chaque extension retournée par l'API
  sets_data['data'].each do |set_data|
    # Créer ou mettre à jour chaque extension dans ta base de données
    extension = Extension.find_or_initialize_by(code: set_data['code'])
    extension.name = set_data['name']
    extension.release_date = set_data['released_at']
    extension.icon_uri = set_data['icon_svg_uri'] # Ou utiliser set_data['set_type'] pour d'autres besoins
    extension.save
  end

  puts "#{Extension.count} extensions have been imported or updated."
rescue OpenURI::HTTPError => e
  puts "Error fetching sets from Scryfall: #{e.message}"
end
