class ChangeTradeStatusToInteger < ActiveRecord::Migration[7.1]
  def up
    # First, ensure all existing records have a valid status
    execute <<-SQL
      UPDATE trades 
      SET status = '0' 
      WHERE status IS NULL OR status = '';
    SQL

    # Then change the column type
    change_column :trades, :status, :integer, using: 'CASE 
      WHEN status = \'0\' THEN 0
      WHEN status = \'1\' THEN 1
      WHEN status = \'2\' THEN 2
      WHEN status = \'3\' THEN 3
      WHEN status = \'4\' THEN 4
      ELSE 0 END'
  end

  def down
    change_column :trades, :status, :string
  end
end
