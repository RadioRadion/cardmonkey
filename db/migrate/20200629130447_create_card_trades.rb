class CreateCardTrades < ActiveRecord::Migration[6.0]
  def change
    create_table :card_trades do |t|
      t.references :trade, null: false, foreign_key: true
      t.references :card, null: false, foreign_key: true

      t.timestamps
    end
  end
end
