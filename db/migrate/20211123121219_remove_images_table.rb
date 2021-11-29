class RemoveImagesTable < ActiveRecord::Migration[6.0]
  def change
    drop_table :images, force: :cascade
  end
end
