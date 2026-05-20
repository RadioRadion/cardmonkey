class AddPerformanceIndexes < ActiveRecord::Migration[7.1]
  def change
    # Index on trades.status for filtering by status (pending, accepted, done)
    add_index :trades, :status, name: 'index_trades_on_status'

    # Composite index for matching queries on user_wanted_cards
    add_index :user_wanted_cards, [:language, :min_condition],
      name: 'index_user_wanted_cards_on_language_and_condition'

    # Indexes for matching filter conditions on user_cards
    add_index :user_cards, :condition, name: 'index_user_cards_on_condition'
    add_index :user_cards, :language, name: 'index_user_cards_on_language'

    # Unique composite index on matches to prevent duplicates and speed up lookups
    add_index :matches, [:user_card_id, :user_wanted_card_id],
      unique: true,
      name: 'index_matches_on_user_card_and_wanted_card_unique'
  end
end
