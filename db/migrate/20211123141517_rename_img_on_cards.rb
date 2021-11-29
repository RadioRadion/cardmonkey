class RenameImgOnCards < ActiveRecord::Migration[6.0]
  def change
    rename_column :cards, :img, :img_uri
  end
end
