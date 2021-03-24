class AddAreaToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :area, :integer
  end
end
