module ConditionHelper
  def condition_icon(condition)
    case condition&.to_sym
    when :mint
      "✨" # Étincelles pour neuf
    when :near_mint
      "🌟" # Étoile pour quasi neuf
    when :excellent
      "⭐" # Étoile pour excellent
    when :good
      "👍" # Pouce levé pour bon
    when :light_played
      "📝" # Crayon pour légèrement joué
    when :played
      "⚡" # Éclair pour joué
    when :poor
      "💢" # Symbole de collision pour mauvais
    else
      "❓" # Point d'interrogation pour condition inconnue
    end
  end

  def condition_with_icon(condition)
    return "" if condition.blank?
    
    icon = condition_icon(condition)
    text = t("cards.conditions.#{condition}")
    "#{icon} #{text}"
  end

  def condition_options_for_select(form_type = :user_card)
    conditions = UserCard.conditions.keys.map do |condition|
      [condition_with_icon(condition), condition]
    end

    if form_type == :user_wanted_card
      conditions.unshift([t("user_wanted_cards.form.any_condition"), ""])
    end

    conditions
  end
end
