class RemoveFieldsOnCards < ActiveRecord::Migration[6.0]
  def change
    remove_column :cards, :condition
    remove_column :cards, :user_id
  end
end
