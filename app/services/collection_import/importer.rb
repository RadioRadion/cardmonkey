module CollectionImport
  # Resolves normalized rows to CardVersions and creates/updates the user's
  # UserCards (idempotent upsert). A normalized row is a Hash with keys:
  #   :scryfall_id, :name, :set, :collector_number, :condition, :language,
  #   :foil, :quantity
  class Importer
    Result = Struct.new(:imported, :updated, :skipped, keyword_init: true) do
      def total_added = imported + updated
      def skipped_count = skipped.size
    end

    def initialize(user)
      @user = user
    end

    def call(rows)
      imported = 0
      updated = 0
      skipped = []

      rows.each_with_index do |row, index|
        card_version = resolve(row)

        if card_version.nil?
          skipped << { line: index + 1, label: label_for(row), reason: "carte introuvable" }
          next
        end

        case upsert(card_version, attributes_for(row))
        when :imported then imported += 1
        when :updated  then updated += 1
        end
      rescue ActiveRecord::RecordInvalid => e
        skipped << { line: index + 1, label: label_for(row), reason: e.message }
      end

      Result.new(imported: imported, updated: updated, skipped: skipped)
    end

    private

    def resolve(row)
      if row[:scryfall_id].present?
        cv = CardVersion.find_by(scryfall_id: row[:scryfall_id])
        return cv if cv
      end

      return nil if row[:name].blank?

      card = find_card(row[:name])
      return nil unless card

      pick_version(card, row[:set], row[:collector_number])
    end

    def find_card(name)
      cleaned = name.to_s.strip
      # Split / DFC names sometimes come as "Front // Back": match the front face too.
      front = cleaned.split("//").first.to_s.strip

      Card.where("LOWER(name_en) = LOWER(:n) OR LOWER(name_fr) = LOWER(:n)", n: cleaned).first ||
        Card.where("LOWER(name_en) = LOWER(:n) OR LOWER(name_fr) = LOWER(:n)", n: front).first ||
        Card.where("name_en ILIKE :n OR name_fr ILIKE :n", n: "#{front}%").first
    end

    def pick_version(card, set_code, collector_number)
      versions = card.card_versions
      if set_code.present?
        scoped = versions.joins(:extension).where("LOWER(extensions.code) = LOWER(?)", set_code.to_s.strip)
        scoped = scoped.where(collector_number: collector_number.to_s.strip) if collector_number.present?
        return scoped.first if scoped.exists?
      end
      versions.order(:id).first
    end

    def attributes_for(row)
      {
        condition: Mappings.condition(row[:condition]),
        language: Mappings.language(row[:language]),
        foil: Mappings.foil(row[:foil]),
        quantity: [row[:quantity].to_i, 1].max
      }
    end

    # Idempotent: re-importing the same version/condition/language/foil bumps the
    # quantity instead of creating a duplicate row.
    def upsert(card_version, attrs)
      existing = @user.user_cards.find_by(
        card_version_id: card_version.id,
        condition: attrs[:condition],
        language: attrs[:language],
        foil: attrs[:foil]
      )

      if existing
        existing.update!(quantity: existing.quantity + attrs[:quantity])
        :updated
      else
        @user.user_cards.create!(card_version: card_version, **attrs)
        :imported
      end
    end

    def label_for(row)
      row[:name].presence || row[:scryfall_id].presence || "ligne #{row.inspect}"
    end
  end
end
