module TradeStatusChecker
  extend ActiveSupport::Concern

  def in_active_trade?
    active_trade_count > 0
  end

  def active_trade_message
    count = active_trade_count
    return nil unless count > 0

    I18n.t('cards.delete_confirmation', count: count)
  end
end
