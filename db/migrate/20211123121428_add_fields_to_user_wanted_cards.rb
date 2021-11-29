class AddFieldsToUserWantedCards < ActiveRecord::Migration[6.0]
  def change
    add_column :user_wanted_cards, :min_condition, :string
    add_column :user_wanted_cards, :foil, :boolean
    add_column :user_wanted_cards, :language, :string
    add_column :user_wanted_cards, :quantity, :integer
  end
end
