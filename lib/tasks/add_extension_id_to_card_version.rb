require 'json'

require_relative '../../config/environment'

json_file_path = Rails.root.join('tmp', 'scryfall', 'all-cards.json')

file = File.read(json_file_path)
cards_data = JSON.parse(file)

cards_data.each do |card_data|
  next unless ['en', 'fr'].include?(card_data['lang'])
  
  # Trouvez l'Extension basée sur le code de l'extension
  extension = Extension.find_by(code: card_data['set'])
  
  if extension
    # Trouvez la CardVersion correspondante et mettez à jour l'extension_id
    CardVersion.where(scryfall_id: card_data['id']).find_each do |card_version|
      card_version.update(extension_id: extension.id)
    end
  else
    puts "No extension found for code #{card_data['set']}. You might need to import this extension first."
  end
end

puts "CardVersions have been updated with their corresponding extensions."
