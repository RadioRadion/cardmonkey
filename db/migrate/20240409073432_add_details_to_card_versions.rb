class AddDetailsToCardVersions < ActiveRecord::Migration[7.1]
  def change
    add_column :card_versions, :border_color, :string
    add_column :card_versions, :frame, :string
    add_column :card_versions, :collector_number, :string
    add_column :card_versions, :rarity, :string
  end
end
