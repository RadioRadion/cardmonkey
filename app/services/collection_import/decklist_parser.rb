module CollectionImport
  # Parses pasted decklists, e.g.:
  #   4 Sol Ring (CMR) 472
  #   1x Black Lotus
  #   Lightning Bolt
  #   2 Arcane Signet *F*
  # Lines starting with // or # (or blank) are ignored. condition/language/foil
  # come from the supplied defaults (a paste carries no per-card metadata).
  module DecklistParser
    module_function

    LINE = /
      \A\s*
      (?<qty>\d+)?\s*x?\s*           # optional quantity, optional 'x'
      (?<name>[^(\n]+?)\s*           # card name (up to a '(' or end)
      (?:\((?<set>[A-Za-z0-9]{2,6})\)\s*(?<num>[^\s]+)?)?  # optional (SET) number
      \s*\z
    /x

    FOIL_MARKERS = ["*f*", "*e*", "(foil)", "(etched)"].freeze

    def parse(content, defaults: {})
      content.to_s.each_line.filter_map do |raw|
        line = raw.strip
        next if line.empty? || line.start_with?("//", "#")

        foil = FOIL_MARKERS.any? { |m| line.downcase.include?(m) }
        line = strip_foil_markers(line)

        match = line.match(LINE)
        next unless match && match[:name].present?

        {
          name: match[:name].strip,
          set: match[:set],
          collector_number: match[:num],
          quantity: match[:qty].presence || "1",
          condition: defaults[:condition],
          language: defaults[:language],
          foil: foil ? "foil" : defaults[:foil]
        }
      end
    end

    def strip_foil_markers(line)
      cleaned = line.dup
      FOIL_MARKERS.each { |m| cleaned = cleaned.gsub(/#{Regexp.escape(m)}/i, "") }
      cleaned.strip
    end
  end
end
