class AddScryfallOracleIdToUserWantedCards < ActiveRecord::Migration[7.1]
  def change
    add_column :user_wanted_cards, :scryfall_oracle_id, :string
  end
end
