class AddMissingIndexesAndTrgm < ActiveRecord::Migration[8.0]
  def change
    # FK columns / hot filter columns that lacked a usable standalone index.
    add_index :trades, :user_id_invit, name: 'index_trades_on_user_id_invit'
    add_index :chatrooms, :user_id_invit, name: 'index_chatrooms_on_user_id_invit'
    add_index :card_versions, :eur_price, name: 'index_card_versions_on_eur_price'

    # Most selective composite for the matching query (card + language).
    add_index :user_wanted_cards, [:card_id, :language],
              name: 'index_user_wanted_cards_on_card_id_and_language'

    # Non-unique on purpose: 2 legacy duplicate usernames exist. Uniqueness is a
    # separate decision (see AUDIT_MVP E14).
    add_index :users, :username, name: 'index_users_on_username'

    # Trigram indexes so `name ILIKE '%query%'` stops doing seq scans on ~31k cards.
    enable_extension 'pg_trgm' unless extension_enabled?('pg_trgm')
    add_index :cards, :name_fr, using: :gin, opclass: :gin_trgm_ops, name: 'index_cards_on_name_fr_trgm'
    add_index :cards, :name_en, using: :gin, opclass: :gin_trgm_ops, name: 'index_cards_on_name_en_trgm'
  end
end
