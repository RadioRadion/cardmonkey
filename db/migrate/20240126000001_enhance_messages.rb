class EnhanceMessages < ActiveRecord::Migration[7.0]
  def change
    unless column_exists?(:messages, :edited_at)
      add_column :messages, :edited_at, :datetime
    end

    unless column_exists?(:messages, :delivered_at)
      add_column :messages, :delivered_at, :datetime
    end

    unless column_exists?(:messages, :parent_id)
      add_column :messages, :parent_id, :bigint
      add_index :messages, :parent_id
    end

    unless table_exists?(:message_reactions)
      create_table :message_reactions do |t|
        t.references :message, null: false, foreign_key: true
        t.references :user, null: false, foreign_key: true
        t.string :emoji, null: false
        t.timestamps
        t.index [:message_id, :user_id, :emoji], unique: true, name: 'index_message_reactions_uniqueness'
      end
    end

    unless column_exists?(:messages, :metadata)
      add_column :messages, :metadata, :jsonb, default: {}, null: false
      add_index :messages, :metadata, using: :gin
    end

    # Add remaining indexes only if they don't exist
    unless index_exists?(:messages, [:chatroom_id, :created_at])
      add_index :messages, [:chatroom_id, :created_at]
    end

    unless index_exists?(:messages, [:user_id, :created_at])
      add_index :messages, [:user_id, :created_at]
    end

    unless index_exists?(:messages, :created_at)
      add_index :messages, :created_at
    end
  end
end
