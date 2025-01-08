class AddResourceIdToNotifications < ActiveRecord::Migration[7.1]
  def change
    add_column :notifications, :resource_id, :integer
    add_index :notifications, [:notification_type, :resource_id]
  end
end
