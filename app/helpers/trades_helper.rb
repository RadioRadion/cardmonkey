module TradesHelper
  def trade_status_badge(trade)
    case trade.status
    when "pending"
      content_tag(:span, "En attente", class: "px-3 py-1 text-sm rounded-full bg-yellow-100 text-yellow-800")
    when "modified"
      content_tag(:span, "Modifié", class: "px-3 py-1 text-sm rounded-full bg-blue-100 text-blue-800")
    when "accepted"
      content_tag(:span, "Accepté", class: "px-3 py-1 text-sm rounded-full bg-green-100 text-green-800")
    when "done"
      content_tag(:span, "Terminé", class: "px-3 py-1 text-sm rounded-full bg-gray-100 text-gray-800")
    when "cancelled"
      content_tag(:span, "Annulé", class: "px-3 py-1 text-sm rounded-full bg-red-100 text-red-800")
    end
  end

  def trade_status_badge_class(status)
    case status.to_s
    when "pending"
      "bg-yellow-100 text-yellow-800"
    when "modified"
      "bg-blue-100 text-blue-800"
    when "accepted"
      "bg-green-100 text-green-800"
    when "done"
      "bg-gray-100 text-gray-800"
    when "cancelled"
      "bg-red-100 text-red-800"
    end
  end

  def trade_status_text(status)
    case status.to_s
    when "pending"
      "En attente"
    when "modified"
      "Modifié"
    when "accepted"
      "Accepté"
    when "done"
      "Terminé"
    when "cancelled"
      "Annulé"
    end
  end
end
