class CreateTradeUserCardsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :trade_user_cards do |t|
      t.references :user_card, null: false, foreign_key: true
      t.references :trade, null: false, foreign_key: true
      t.timestamps
    end
  end
end
