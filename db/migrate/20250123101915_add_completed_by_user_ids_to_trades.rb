class AddCompletedByUserIdsToTrades < ActiveRecord::Migration[7.1]
  def change
    add_column :trades, :completed_by_user_ids, :integer, array: true, default: []
  end
end
