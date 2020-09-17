class AddPricetoImages < ActiveRecord::Migration[6.0]
  def change
    add_column :images, :price, :string
  end
end
