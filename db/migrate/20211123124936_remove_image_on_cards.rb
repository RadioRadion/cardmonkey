class RemoveImageOnCards < ActiveRecord::Migration[6.0]
  def change
    remove_column :cards, :image_id
  end
end
