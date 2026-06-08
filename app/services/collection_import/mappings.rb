module CollectionImport
  # Normalizes the free-form values found in scanner / collection-app exports
  # (ManaBox, Moxfield, Deckbox...) to the app's internal enums.
  module Mappings
    module_function

    CONDITIONS = {
      "m" => "mint", "mint" => "mint",
      "nm" => "near_mint", "near mint" => "near_mint", "near_mint" => "near_mint",
      "ex" => "excellent", "excellent" => "excellent",
      "gd" => "good", "good" => "good",
      "sp" => "light_played", "lp" => "light_played",
      "lightly played" => "light_played", "light_played" => "light_played",
      "good (lightly played)" => "light_played",
      "mp" => "played", "pl" => "played", "played" => "played",
      "moderately played" => "played",
      "hp" => "poor", "heavily played" => "poor", "poor" => "poor",
      "dmg" => "poor", "damaged" => "poor"
    }.freeze

    SUPPORTED_LANGUAGES = %w[en fr de it ja pt ru ko zhs zht].freeze

    LANGUAGE_ALIASES = {
      "english" => "en", "anglais" => "en",
      "french" => "fr", "français" => "fr", "francais" => "fr",
      "german" => "de", "allemand" => "de", "deutsch" => "de",
      "italian" => "it", "italien" => "it", "italiano" => "it",
      "japanese" => "ja", "japonais" => "ja", "jp" => "ja",
      "portuguese" => "pt", "portugais" => "pt",
      "russian" => "ru", "russe" => "ru",
      "korean" => "ko", "coréen" => "ko", "coreen" => "ko",
      "chinese" => "zhs", "chinese simplified" => "zhs", "cs" => "zhs",
      "chinese traditional" => "zht", "ct" => "zht"
    }.freeze

    FOIL_TRUE = %w[foil etched true yes 1 oui].freeze

    def condition(value, default: "near_mint")
      key = value.to_s.strip.downcase
      return default if key.empty?

      CONDITIONS[key] || default
    end

    def language(value, default: "en")
      key = value.to_s.strip.downcase
      return default if key.empty?
      return key if SUPPORTED_LANGUAGES.include?(key)

      LANGUAGE_ALIASES[key] || default
    end

    def foil(value)
      FOIL_TRUE.include?(value.to_s.strip.downcase)
    end
  end
end
