class ChangeFieldsToCards < ActiveRecord::Migration[6.0]
  def change
    add_column :cards, :price, :float
    add_column :cards, :img_path, :string
    add_column :cards, :scryfall_id, :string
    rename_column :cards, :uuid, :scryfall_oracle_id
    remove_column :cards, :quantity
    remove_column :cards, :foil
    remove_column :cards, :language
    remove_column :cards, :image_id
  end
end
