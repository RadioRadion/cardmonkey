class AddScryfallUniqueIndexes < ActiveRecord::Migration[8.0]
  def change
    # Enforce one CardVersion per Scryfall print id (replaces the non-unique index).
    remove_index :card_versions, name: 'index_card_versions_on_scryfall_id'
    add_index :card_versions, :scryfall_id, unique: true, name: 'index_card_versions_on_scryfall_id'

    # Enforce one Card per Scryfall oracle id (Postgres treats NULLs as distinct,
    # so the lone legacy NULL row is tolerated).
    add_index :cards, :scryfall_oracle_id, unique: true, name: 'index_cards_on_scryfall_oracle_id'
  end
end
