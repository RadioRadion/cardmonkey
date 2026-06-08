require "rails_helper"

RSpec.describe CollectionImport do
  let(:user) { create(:user) }

  describe CollectionImport::Mappings do
    it "maps common condition labels to the internal enum" do
      expect(described_class.condition("NM")).to eq("near_mint")
      expect(described_class.condition("Lightly Played")).to eq("light_played")
      expect(described_class.condition("HP")).to eq("poor")
      expect(described_class.condition("")).to eq("near_mint")
      expect(described_class.condition("wat", default: "good")).to eq("good")
    end

    it "maps languages by code and name" do
      expect(described_class.language("English")).to eq("en")
      expect(described_class.language("fr")).to eq("fr")
      expect(described_class.language("")).to eq("en")
      expect(described_class.language("klingon")).to eq("en")
    end

    it "detects foil" do
      expect(described_class.foil("foil")).to be true
      expect(described_class.foil("etched")).to be true
      expect(described_class.foil("")).to be false
    end
  end

  describe CollectionImport::DecklistParser do
    it "parses quantities, names, set and collector number" do
      rows = described_class.parse("4 Sol Ring (CMR) 472\n1x Black Lotus\n# comment\n\nLightning Bolt",
                                   defaults: { condition: "near_mint", language: "en" })
      expect(rows.size).to eq(3)
      expect(rows[0]).to include(name: "Sol Ring", set: "CMR", collector_number: "472", quantity: "4")
      expect(rows[1]).to include(name: "Black Lotus", quantity: "1")
      expect(rows[2]).to include(name: "Lightning Bolt", quantity: "1")
    end

    it "detects a foil marker" do
      rows = described_class.parse("2 Arcane Signet *F*", defaults: { foil: nil })
      expect(rows.first).to include(name: "Arcane Signet", foil: "foil")
    end
  end

  describe CollectionImport::CsvParser do
    it "parses a Moxfield-style export (headers by name, any order)" do
      csv = "Count,Name,Edition,Condition,Language,Foil\n3,Black Lotus,LEA,NM,English,\n1,Sol Ring,CMR,LP,French,foil\n"
      rows = described_class.parse(csv, defaults: {})
      expect(rows.size).to eq(2)
      expect(rows[0]).to include(name: "Black Lotus", set: "LEA", condition: "NM", quantity: "3")
      expect(rows[1]).to include(name: "Sol Ring", foil: "foil", language: "French")
    end

    it "uses the Scryfall ID column when present" do
      csv = "Name,Scryfall ID,Quantity\nBlack Lotus,abc-123,2\n"
      rows = described_class.parse(csv, defaults: {})
      expect(rows.first).to include(scryfall_id: "abc-123", quantity: "2")
    end
  end

  describe CollectionImport::Importer do
    let(:extension) { create(:extension, code: "LEA") }
    let!(:card) { create(:card, name_en: "Black Lotus", name_fr: "Lotus Noir") }
    let!(:version) { create(:card_version, card: card, extension: extension, scryfall_id: "sf-lotus") }

    it "resolves by Scryfall ID and creates a UserCard" do
      rows = [{ scryfall_id: "sf-lotus", condition: "NM", language: "en", quantity: "2" }]
      result = described_class.new(user).call(rows)

      expect(result.imported).to eq(1)
      uc = user.user_cards.first
      expect(uc.card_version).to eq(version)
      expect(uc.quantity).to eq(2)
      expect(uc.condition).to eq("near_mint")
    end

    it "resolves by name (case-insensitive, fr or en)" do
      rows = [{ name: "lotus noir", condition: "LP", language: "fr", quantity: "1" }]
      result = described_class.new(user).call(rows)

      expect(result.imported).to eq(1)
      expect(user.user_cards.first.card_version.card).to eq(card)
      expect(user.user_cards.first.condition).to eq("light_played")
    end

    it "upserts: re-importing the same version bumps the quantity" do
      rows = [{ scryfall_id: "sf-lotus", condition: "NM", language: "en", quantity: "2" }]
      described_class.new(user).call(rows)
      result = described_class.new(user).call(rows)

      expect(result.updated).to eq(1)
      expect(user.user_cards.count).to eq(1)
      expect(user.user_cards.first.quantity).to eq(4)
    end

    it "reports unresolved rows as skipped" do
      rows = [{ name: "Carte Inexistante XYZ", quantity: "1" }]
      result = described_class.new(user).call(rows)

      expect(result.imported).to eq(0)
      expect(result.skipped_count).to eq(1)
      expect(result.skipped.first[:reason]).to eq("carte introuvable")
    end
  end
end
