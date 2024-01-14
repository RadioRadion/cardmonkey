class RemoveNameFromCards < ActiveRecord::Migration[6.0]
  def change
    remove_column :cards, :name, :string
  end
end
