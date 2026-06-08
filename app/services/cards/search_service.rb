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
          .where("name_en ILIKE :q OR name_fr ILIKE :q", q: "%#{sanitize_like(@query)}%")
          .distinct
          .limit(10)
          .map do |card|
            {
              id: card.id,
              name: card.name_en,
              name_fr: card.name_fr,
              scryfall_id: card.card_versions.first&.scryfall_id,
              versions: card.card_versions.map do |version|
                {
                  id: version.id,
                  extension_name: version.extension&.name,
                  set_code: version.extension&.code
                }
              end
            }
          end
    end

    private

    # Escape LIKE wildcards typed by the user so "%" / "_" are literal.
    def sanitize_like(value)
      value.to_s.gsub(/[\\%_]/) { |char| "\\#{char}" }
    end
  end
end
