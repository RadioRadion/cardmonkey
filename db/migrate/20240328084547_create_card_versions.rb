class CreateCardVersions < ActiveRecord::Migration[7.1]
  def change
    create_table :card_versions do |t|
      t.references :card, null: false, foreign_key: true
      t.string :extension
      t.string :scryfall_id
      t.string :img_uri
      t.decimal :price

      t.timestamps
    end
  end
end
