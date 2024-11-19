module UserCardsHelper
  def condition_label(condition)
    I18n.t("cards.conditions.#{condition}", default: condition)
  end

  def language_label(language)
    # Debug
    Rails.logger.debug "Language value: #{language.inspect}"
    
    return '-' if language.blank?

    flags = {
      'french' => '🇫🇷',
      'english' => '🇬🇧',
      'german' => '🇩🇪',
      'italian' => '🇮🇹',
      'simplified_chinese' => '🇨🇳',
      'traditional_chinese' => '🇹🇼',
      'japanese' => '🇯🇵',
      'portuguese' => '🇵🇹',
      'russian' => '🇷🇺',
      'korean' => '🇰🇷'
    }

    # Récupérer la clé de l'enum à partir de la valeur
    lang_key = language.to_s

    flag = flags[lang_key] || ''
    name = I18n.t("cards.languages.#{lang_key}", default: lang_key.humanize)
    
    (flag + ' ' + name).html_safe
  end

  def rarity_label(rarity)
    I18n.t("cards.rarity.#{rarity}", default: rarity)
  end

  def rarity_color(rarity)
    {
      'common' => 'bg-gray-400',
      'uncommon' => 'bg-blue-400',
      'rare' => 'bg-yellow-400',
      'mythic' => 'bg-red-600'
    }[rarity] || 'bg-gray-400'
  end
end