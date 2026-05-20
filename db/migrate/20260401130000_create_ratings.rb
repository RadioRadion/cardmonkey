class CreateRatings < ActiveRecord::Migration[7.1]
  def change
    create_table :ratings do |t|
      t.references :trade, null: false, foreign_key: true
      t.references :rater, null: false, foreign_key: { to_table: :users }
      t.references :rated, null: false, foreign_key: { to_table: :users }
      t.integer :score, null: false
      t.text :comment

      t.timestamps
    end

    add_index :ratings, [:trade_id, :rater_id], unique: true, name: 'index_ratings_on_trade_and_rater'
  end
end
