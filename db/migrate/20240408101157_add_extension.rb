class AddExtension < ActiveRecord::Migration[7.1]
  
  def change
    create_table :extensions do |t|
      t.string :code, null: false
      t.string :name
      t.date :release_date
      t.string :icon_uri

      t.timestamps

    end

    add_index :extensions, :code, unique: true

    add_reference :card_versions, :extension, null: true, foreign_key: true
  end
end
