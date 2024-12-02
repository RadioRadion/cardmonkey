module ConditionHelper
  def condition_label(condition)
    return "" if condition.blank?
    return t("wants.conditions.unimportant") if condition == "unimportant"
    
    # For user_wanted_cards, keep using translations
    return t("activerecord.enums.user_card.condition.#{condition}") if @form_type == :user_wanted_card
    
    # For user_cards, use direct values
    condition.humanize
  end

  def condition_options_for_select(form_type = :user_card)
    @form_type = form_type
    
    if form_type == :user_wanted_card
      # Keep translations for user_wanted_cards
      conditions = UserCard.conditions.keys.map do |condition|
        [t("activerecord.enums.user_card.condition.#{condition}"), condition]
      end
      conditions.unshift([t("user_wanted_cards.form.any_condition"), "unimportant"])
    else
      # Direct values for user_cards
      conditions = UserCard.conditions.keys.map do |condition|
        [condition.humanize, condition]
      end
    end

    conditions
  end
end
