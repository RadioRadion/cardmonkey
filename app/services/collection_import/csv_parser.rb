require "csv"

module CollectionImport
  # Parses CSV exports from the common scanner / collection apps (ManaBox,
  # Moxfield, Deckbox). Columns are matched by header NAME (case-insensitive,
  # order-independent) since there is no universal standard.
  module CsvParser
    module_function

    COLUMN_ALIASES = {
      scryfall_id: ["scryfall id", "scryfall_id", "scryfallid"],
      name: ["name", "card name", "card", "nom"],
      set: ["set code", "set", "edition", "set name", "set_code"],
      collector_number: ["collector number", "collector_number", "card number", "number", "collectornumber"],
      condition: ["condition", "état", "etat"],
      language: ["language", "lang", "langue"],
      foil: ["foil", "finish", "printing", "foil/etched"],
      quantity: ["count", "quantity", "qty", "quantité", "quantite"]
    }.freeze

    # Returns an array of normalized rows. `defaults` fills condition/language/foil
    # when the file does not carry them.
    def parse(content, defaults: {})
      table = CSV.parse(content.to_s, headers: true, skip_blanks: true)
      header_map = build_header_map(table.headers)

      table.filter_map do |csv_row|
        row = extract(csv_row, header_map)
        next if row[:name].blank? && row[:scryfall_id].blank?

        apply_defaults(row, defaults)
      end
    rescue CSV::MalformedCSVError => e
      raise ArgumentError, "Fichier CSV invalide : #{e.message}"
    end

    def build_header_map(headers)
      normalized = headers.compact.index_by { |h| h.to_s.strip.downcase }
      COLUMN_ALIASES.transform_values do |aliases|
        key = aliases.find { |a| normalized.key?(a) }
        normalized[key] if key
      end.compact
    end

    def extract(csv_row, header_map)
      header_map.transform_values { |header| csv_row[header].to_s.strip.presence }
    end

    def apply_defaults(row, defaults)
      row[:condition] = row[:condition].presence || defaults[:condition]
      row[:language]  = row[:language].presence || defaults[:language]
      row[:foil]      = row[:foil].presence || defaults[:foil]
      row[:quantity]  = row[:quantity].presence || "1"
      row
    end
  end
end
