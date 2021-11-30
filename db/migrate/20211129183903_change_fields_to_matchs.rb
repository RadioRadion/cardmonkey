class ChangeFieldsToMatchs < ActiveRecord::Migration[6.0]
  def change
    remove_column :matches, :card_id
    remove_column :matches, :want_id
    add_reference :matches, :user_card, index: true
    add_reference :matches, :user_wanted_card, index: true
    add_reference :matches, :user, index: true
    add_column :matches, :user_id_target, :integer, null: false
  end
end
