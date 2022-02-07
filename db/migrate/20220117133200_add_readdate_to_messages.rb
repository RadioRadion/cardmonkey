class AddReaddateToMessages < ActiveRecord::Migration[6.0]
  def change
    add_column :messages, :read_date, :datetime
    add_column :messages, :is_new, :boolean, default: true
  end
end
