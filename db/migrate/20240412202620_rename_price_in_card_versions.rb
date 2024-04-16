class RenamePriceInCardVersions < ActiveRecord::Migration[7.1]
  def change
    rename_column :card_versions, :price, :eur_price
    add_column :card_versions, :eur_foil_price, :decimal, precision: 10, scale: 2
  end
end
