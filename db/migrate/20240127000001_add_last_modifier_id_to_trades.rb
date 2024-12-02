class AddLastModifierIdToTrades < ActiveRecord::Migration[7.1]
  def change
    add_column :trades, :last_modifier_id, :integer
    add_index :trades, :last_modifier_id
  end
end
