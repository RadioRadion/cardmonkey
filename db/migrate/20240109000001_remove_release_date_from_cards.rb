class RemoveReleaseDateFromCards < ActiveRecord::Migration[7.0]
  def change
    remove_column :cards, :release_date, :date
  end
end
