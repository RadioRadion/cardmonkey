class CreateImages < ActiveRecord::Migration[6.0]
  def change
    create_table :images do |t|
      t.string :api_id
      t.string :img_path

      t.timestamps
    end
  end
end
