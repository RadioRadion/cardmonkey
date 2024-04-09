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

ActiveRecord::Schema[7.1].define(version: 2024_04_09_073432) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "card_versions", force: :cascade do |t|
    t.bigint "card_id", null: false
    t.string "scryfall_id"
    t.string "img_uri"
    t.decimal "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "extension_id"
    t.string "border_color"
    t.string "frame"
    t.string "collector_number"
    t.string "rarity"
    t.index ["card_id"], name: "index_card_versions_on_card_id"
    t.index ["extension_id"], name: "index_card_versions_on_extension_id"
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
    t.index ["user_id"], name: "index_matches_on_user_id"
    t.index ["user_wanted_card_id"], name: "index_matches_on_user_wanted_card_id"
  end

  create_table "messages", force: :cascade do |t|
    t.string "content"
    t.bigint "user_id", null: false
    t.bigint "chatroom_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chatroom_id"], name: "index_messages_on_chatroom_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "content", null: false
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notifications_on_user_id"
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
    t.string "status"
    t.bigint "user_id", null: false
    t.integer "user_id_invit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "card_versions", "cards"
  add_foreign_key "card_versions", "extensions"
  add_foreign_key "chatrooms", "users"
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
