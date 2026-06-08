class AddDbConstraintsAndNotNull < ActiveRecord::Migration[8.0]
  def up
    # One chatroom per ordered user pair (matches the Rails uniqueness validation).
    add_index :chatrooms, [:user_id, :user_id_invit],
              unique: true, name: 'index_chatrooms_on_user_and_invit_unique'

    # Self-matches must never exist; insert_all bypasses the model validation.
    add_check_constraint :matches, 'user_id <> user_id_target', name: 'matches_no_self_match'

    # Backfill localized names (mirrors the importer) so the column can be NOT NULL.
    execute "UPDATE cards SET name_fr = name_en WHERE name_fr IS NULL AND name_en IS NOT NULL"

    change_column_null :cards, :name_en, false
    change_column_null :cards, :name_fr, false

    change_column_null :card_versions, :scryfall_id, false
    change_column_null :card_versions, :extension_id, false
    change_column_null :card_versions, :rarity, false
    change_column_null :card_versions, :frame, false
    change_column_null :card_versions, :border_color, false

    change_column_null :user_cards, :condition, false
    change_column_null :user_cards, :language, false
    change_column_null :user_cards, :quantity, false
    change_column_null :user_cards, :foil, false

    change_column_null :user_wanted_cards, :min_condition, false
    change_column_null :user_wanted_cards, :language, false
    change_column_null :user_wanted_cards, :quantity, false
    change_column_null :user_wanted_cards, :foil, false

    change_column_null :matches, :user_card_id, false
    change_column_null :matches, :user_wanted_card_id, false
    change_column_null :matches, :user_id, false
  end

  def down
    change_column_null :matches, :user_id, true
    change_column_null :matches, :user_wanted_card_id, true
    change_column_null :matches, :user_card_id, true

    change_column_null :user_wanted_cards, :foil, true
    change_column_null :user_wanted_cards, :quantity, true
    change_column_null :user_wanted_cards, :language, true
    change_column_null :user_wanted_cards, :min_condition, true

    change_column_null :user_cards, :foil, true
    change_column_null :user_cards, :quantity, true
    change_column_null :user_cards, :language, true
    change_column_null :user_cards, :condition, true

    change_column_null :card_versions, :border_color, true
    change_column_null :card_versions, :frame, true
    change_column_null :card_versions, :rarity, true
    change_column_null :card_versions, :extension_id, true
    change_column_null :card_versions, :scryfall_id, true

    change_column_null :cards, :name_fr, true
    change_column_null :cards, :name_en, true

    remove_check_constraint :matches, name: 'matches_no_self_match'
    remove_index :chatrooms, name: 'index_chatrooms_on_user_and_invit_unique'
  end
end
