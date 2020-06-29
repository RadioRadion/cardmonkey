class CreateCards < ActiveRecord::Migration[6.0]
  def change
    create_table :cards do |t|
      t.string :uuid
      t.string :condition
      t.boolean :foil
      t.string :img
      t.string :language
      t.string :extension
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
