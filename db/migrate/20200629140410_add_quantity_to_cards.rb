class AddQuantityToCards < ActiveRecord::Migration[6.0]
  def change
    add_column :cards, :quantity, :string
  end
end
