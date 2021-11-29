class RemoveCardTradeTable < ActiveRecord::Migration[6.0]
  def change
    drop_table :card_trades
  end
end
