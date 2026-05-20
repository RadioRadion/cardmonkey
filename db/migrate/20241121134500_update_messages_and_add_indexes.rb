class UpdateMessagesAndAddIndexes < ActiveRecord::Migration[7.0]
  def change
    # Add read_at column if it doesn't exist
    unless column_exists?(:messages, :read_at)
      add_column :messages, :read_at, :datetime
      add_index :messages, :read_at
    end
    
    # Add indexes if they don't exist
    unless index_exists?(:messages, [:chatroom_id, :created_at])
      add_index :messages, [:chatroom_id, :created_at]
    end
    
    unless index_exists?(:messages, [:user_id, :chatroom_id])
      add_index :messages, [:user_id, :chatroom_id]
    end
  end
end
