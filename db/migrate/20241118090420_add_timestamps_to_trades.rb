class AddTimestampsToTrades < ActiveRecord::Migration[7.1]
  def change
    add_column :trades, :accepted_at, :datetime
    add_column :trades, :completed_at, :datetime
  end
end