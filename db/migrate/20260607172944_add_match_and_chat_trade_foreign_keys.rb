class AddMatchAndChatTradeForeignKeys < ActiveRecord::Migration[8.0]
  def change
    # matches had no referential integrity at all (the largest table).
    add_foreign_key :matches, :user_cards, column: :user_card_id
    add_foreign_key :matches, :user_wanted_cards, column: :user_wanted_card_id
    add_foreign_key :matches, :users, column: :user_id
    add_foreign_key :matches, :users, column: :user_id_target

    # Second participant / modifier columns were unprotected. Nullable columns
    # with NULL values are simply skipped by the FK.
    add_foreign_key :chatrooms, :users, column: :user_id_invit
    add_foreign_key :trades, :users, column: :user_id_invit
    add_foreign_key :trades, :users, column: :last_modifier_id
  end
end
