module Cards
  class SearchService
    def self.call(query)
      new(query).call
    end

    def initialize(query)
      @query = query
    end

    def call
      Card.joins(:card_versions)
          .includes(card_versions: :extension)
          .where("LOWER(name_en) LIKE LOWER(?)", "%#{@query}%")
          .limit(10)
          .map do |card|
            {
              id: card.id,
              name: card.name_en,
              scryfall_id: card.card_versions.first.scryfall_id,
              versions: card.card_versions.map do |version|
                {
                  id: version.id,
                  extension_name: version.extension.name,
                  set_code: version.extension.code
                }
              end
            }
          end
    end
  end
end
