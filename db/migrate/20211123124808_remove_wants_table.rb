class RemoveWantsTable < ActiveRecord::Migration[6.0]
  def change
    drop_table :wants, force: :cascade
  end
end
