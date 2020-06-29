class CreateTrades < ActiveRecord::Migration[6.0]
  def change
    create_table :trades do |t|
      t.string :status
      t.references :user, null: false, foreign_key: true
      t.integer :user_id_invit

      t.timestamps
    end
  end
end
