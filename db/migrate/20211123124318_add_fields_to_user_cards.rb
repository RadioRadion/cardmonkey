class AddFieldsToUserCards < ActiveRecord::Migration[6.0]
  def change
    add_column :user_cards, :condition, :string
    add_column :user_cards, :foil, :boolean
    add_column :user_cards, :language, :string
    add_column :user_cards, :quantity, :integer
  end
end
