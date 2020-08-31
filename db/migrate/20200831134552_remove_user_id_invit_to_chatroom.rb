class RemoveUserIdInvitToChatroom < ActiveRecord::Migration[6.0]
  def change
        remove_column :chatrooms, :user_id_invit, :string
  end
end
