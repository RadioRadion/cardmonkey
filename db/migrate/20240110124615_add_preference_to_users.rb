class AddPreferenceToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :preference, :integer, default: 0
  end
end
