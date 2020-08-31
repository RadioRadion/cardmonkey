class AddUserIdinvitToChatroom < ActiveRecord::Migration[6.0]
  def change
    add_column :chatrooms, :user_id_invit, :integer
  end
end
