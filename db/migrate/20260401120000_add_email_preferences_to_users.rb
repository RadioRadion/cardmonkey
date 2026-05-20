class AddEmailPreferencesToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :email_notifications, :boolean, default: true, null: false
    add_column :users, :email_digest, :string, default: 'instant', null: false
  end
end
