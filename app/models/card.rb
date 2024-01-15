require "down"
require "fileutils"
require "net/http"

class Card < ApplicationRecord

  has_many :user_cards
  has_many :user_wanted_cards

  validates :extension, presence: true

  def name(preferred_language = :en)
    case preferred_language
    when :en
      name_en
    when :fr
      name_fr
    else
      name_en
    end
  end

##Méthode pour fetch dans le seed.rb
  def self.fetch_cards(extension)
    puts "extension #{extension} en cours d'import..."
    url = URI("https://api.scryfall.com/cards/search?order=set&q=e%3A#{extension}&unique=prints")
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Get.new(url)

    response = https.request(request)
    response2 = JSON.parse(response.body)
    response2["data"].first(10).each do |card|
      Card.create!(
        scryfall_id: card["id"],
        img_uri: card["image_uris"]["border_crop"],
        img_path: "./app/assets/images/cards/#{extension}/#{card["id"]}.jpg",
        extension: card["set"],
        name: card["name"],
        price: card["prices"]["eur"]
        )
      tempfile = Down.download(card["image_uris"]["border_crop"])
      FileUtils.mv(tempfile.path, "./app/assets/images/cards/#{extension}/#{card["id"]}.jpg")
      puts "#{card["name"]} importée"
    end
    puts "import terminé."
  end

end
