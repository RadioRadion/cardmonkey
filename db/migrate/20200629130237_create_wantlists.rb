class CreateWantlists < ActiveRecord::Migration[6.0]
  def change
    create_table :wantlists do |t|
      t.string :name
      t.integer :quantity
      t.string :extension
      t.string :min_cond
      t.boolean :foil
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
