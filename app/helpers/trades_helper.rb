# app/helpers/trades_helper.rb
module TradesHelper
  def trade_status_classes(status)
    case status
    when "pending"
      "bg-yellow-100 text-yellow-800"
    when "accepted"
      "bg-blue-100 text-blue-800"
    when "done"
      "bg-green-100 text-green-800"
    else
      "bg-gray-100 text-gray-800"
    end
  end

  def trade_value_difference_classes(difference)
    if difference == 0
      "text-green-600"
    elsif difference.positive?
      "text-red-600"
    else
      "text-blue-600"
    end
  end

  def card_count_text(trade)
    count = trade.user_cards.size
    "#{count} #{'carte'.pluralize(count)}"
  end
  
end