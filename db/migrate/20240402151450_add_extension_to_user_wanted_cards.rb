class AddExtensionToUserWantedCards < ActiveRecord::Migration[7.1]
  def change
    add_column :user_wanted_cards, :extension_name, :string
  end
end
