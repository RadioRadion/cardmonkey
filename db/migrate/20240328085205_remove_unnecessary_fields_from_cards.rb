class RemoveUnnecessaryFieldsFromCards < ActiveRecord::Migration[7.1]
  def change
    remove_column :cards, :img_uri, :string
    remove_column :cards, :extension, :string
    remove_column :cards, :price, :decimal
    remove_column :cards, :img_path, :string
    remove_column :cards, :scryfall_id, :string
  end
end
