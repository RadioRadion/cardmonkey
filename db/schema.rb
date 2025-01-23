# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_01_23_101915) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "card_legalities", force: :cascade do |t|
    t.bigint "card_id", null: false
    t.string "format", null: false
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["card_id", "format"], name: "index_card_legalities_on_card_id_and_format", unique: true
    t.index ["card_id"], name: "index_card_legalities_on_card_id"
    t.check_constraint "status::text = ANY (ARRAY['legal'::character varying, 'not_legal'::character varying, 'restricted'::character varying, 'banned'::character varying]::text[])", name: "check_legality_status"
  end

  create_table "card_versions", force: :cascade do |t|
    t.bigint "card_id", null: false
    t.string "scryfall_id"
    t.string "img_uri"
    t.decimal "eur_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "extension_id"
    t.string "border_color"
    t.string "frame"
    t.string "collector_number"
    t.string "rarity"
    t.decimal "eur_foil_price", precision: 10, scale: 2
    t.index ["card_id", "extension_id"], name: "index_card_versions_on_card_and_extension"
    t.index ["card_id"], name: "index_card_versions_on_card_id"
    t.index ["extension_id"], name: "index_card_versions_on_extension_id"
    t.index ["scryfall_id"], name: "index_card_versions_on_scryfall_id"
  end

  create_table "cards", force: :cascade do |t|
    t.string "scryfall_oracle_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name_en"
    t.string "name_fr"
  end

  create_table "chatrooms", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.integer "user_id_invit"
    t.index ["user_id"], name: "index_chatrooms_on_user_id"
  end

  create_table "extensions", force: :cascade do |t|
    t.string "code", null: false
    t.string "name"
    t.date "release_date"
    t.string "icon_uri"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_extensions_on_code", unique: true
  end

  create_table "matches", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_card_id"
    t.bigint "user_wanted_card_id"
    t.bigint "user_id"
    t.integer "user_id_target", null: false
    t.index ["user_card_id"], name: "index_matches_on_user_card_id"
    t.index ["user_id", "user_id_target"], name: "index_matches_on_user_and_target"
    t.index ["user_id"], name: "index_matches_on_user_id"
    t.index ["user_id_target", "user_id"], name: "index_matches_on_target_and_user"
    t.index ["user_wanted_card_id"], name: "index_matches_on_user_wanted_card_id"
  end

  create_table "message_reactions", force: :cascade do |t|
    t.bigint "message_id", null: false
    t.bigint "user_id", null: false
    t.string "emoji", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id", "user_id", "emoji"], name: "index_message_reactions_uniqueness", unique: true
    t.index ["message_id"], name: "index_message_reactions_on_message_id"
    t.index ["user_id"], name: "index_message_reactions_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.string "content"
    t.bigint "user_id", null: false
    t.bigint "chatroom_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "read_at"
    t.datetime "edited_at"
    t.datetime "delivered_at"
    t.bigint "parent_id"
    t.jsonb "metadata", default: {}, null: false
    t.index ["chatroom_id", "created_at"], name: "index_messages_on_chatroom_id_and_created_at"
    t.index ["chatroom_id"], name: "index_messages_on_chatroom_id"
    t.index ["created_at"], name: "index_messages_on_created_at"
    t.index ["metadata"], name: "index_messages_on_metadata", using: :gin
    t.index ["parent_id"], name: "index_messages_on_parent_id"
    t.index ["read_at"], name: "index_messages_on_read_at"
    t.index ["user_id", "chatroom_id"], name: "index_messages_on_user_id_and_chatroom_id"
    t.index ["user_id", "created_at"], name: "index_messages_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "content", null: false
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "notification_type"
    t.datetime "read_at"
    t.integer "resource_id"
    t.index ["notification_type", "resource_id"], name: "index_notifications_on_notification_type_and_resource_id"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "supported_languages", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_supported_languages_on_code", unique: true
  end

  create_table "trade_user_cards", force: :cascade do |t|
    t.bigint "user_card_id", null: false
    t.bigint "trade_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trade_id"], name: "index_trade_user_cards_on_trade_id"
    t.index ["user_card_id"], name: "index_trade_user_cards_on_user_card_id"
  end

  create_table "trades", force: :cascade do |t|
    t.integer "status"
    t.bigint "user_id", null: false
    t.integer "user_id_invit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "accepted_at"
    t.datetime "completed_at"
    t.integer "last_modifier_id"
    t.integer "completed_by_user_ids", default: [], array: true
    t.index ["last_modifier_id"], name: "index_trades_on_last_modifier_id"
    t.index ["user_id", "user_id_invit"], name: "index_trades_on_user_and_invit"
    t.index ["user_id"], name: "index_trades_on_user_id"
  end

  create_table "user_cards", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "condition"
    t.boolean "foil"
    t.string "language"
    t.integer "quantity"
    t.bigint "card_version_id", null: false
    t.index ["card_version_id"], name: "index_user_cards_on_card_version_id"
    t.index ["user_id", "card_version_id"], name: "index_user_cards_on_user_and_card_version"
    t.index ["user_id"], name: "index_user_cards_on_user_id"
  end

  create_table "user_wanted_cards", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "card_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "min_condition"
    t.boolean "foil"
    t.string "language"
    t.integer "quantity"
    t.bigint "card_version_id"
    t.index ["card_id"], name: "index_user_wanted_cards_on_card_id"
    t.index ["card_version_id"], name: "index_user_wanted_cards_on_card_version_id"
    t.index ["user_id", "card_id", "card_version_id"], name: "index_user_wanted_cards_on_user_card_and_version"
    t.index ["user_id"], name: "index_user_wanted_cards_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.float "latitude"
    t.float "longitude"
    t.string "address"
    t.integer "area"
    t.integer "preference", default: 0
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["latitude", "longitude"], name: "index_users_on_coordinates"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "card_legalities", "cards"
  add_foreign_key "card_versions", "cards"
  add_foreign_key "card_versions", "extensions"
  add_foreign_key "chatrooms", "users"
  add_foreign_key "message_reactions", "messages"
  add_foreign_key "message_reactions", "users"
  add_foreign_key "messages", "chatrooms"
  add_foreign_key "messages", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "trade_user_cards", "trades"
  add_foreign_key "trade_user_cards", "user_cards"
  add_foreign_key "trades", "users"
  add_foreign_key "user_cards", "card_versions"
  add_foreign_key "user_cards", "users"
  add_foreign_key "user_wanted_cards", "card_versions"
  add_foreign_key "user_wanted_cards", "cards"
  add_foreign_key "user_wanted_cards", "users"
end
