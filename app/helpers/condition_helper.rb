module ConditionHelper
    def condition(condition)
      case condition
      when "poor"
        content_tag(:span, "P", class: "px-2 py-1 text-white bg-red-600 rounded")
      when "played"
        content_tag(:span, "PL", class: "px-2 py-1 text-white bg-red-400 rounded")
      when "light_played"
        content_tag(:span, "LP", class: "px-2 py-1 text-white bg-orange-400 rounded")
      when "good"
        content_tag(:span, "G", class: "px-2 py-1 text-white bg-yellow-400 rounded")
      when "excellent"
        content_tag(:span, "E", class: "px-2 py-1 text-white bg-green-300 rounded")
      when "near_mint"
        content_tag(:span, "NM", class: "px-2 py-1 text-white bg-green-500 rounded")
      when "mint"
        content_tag(:span, "M", class: "px-2 py-1 text-white bg-green-700 rounded")
      else
        condition
      end
    end
  end
  