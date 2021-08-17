# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_08_17_072647) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "card_trades", force: :cascade do |t|
    t.bigint "trade_id", null: false
    t.bigint "card_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["card_id"], name: "index_card_trades_on_card_id"
    t.index ["trade_id"], name: "index_card_trades_on_trade_id"
  end

  create_table "cards", force: :cascade do |t|
    t.string "uuid"
    t.string "condition"
    t.boolean "foil"
    t.string "img"
    t.string "language"
    t.string "extension"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
    t.string "quantity"
    t.bigint "image_id"
    t.index ["image_id"], name: "index_cards_on_image_id"
    t.index ["user_id"], name: "index_cards_on_user_id"
  end

  create_table "chatrooms", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id"
    t.integer "user_id_invit"
    t.index ["user_id"], name: "index_chatrooms_on_user_id"
  end

  create_table "images", force: :cascade do |t|
    t.string "api_id"
    t.string "img_path"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "price"
  end

  create_table "matches", force: :cascade do |t|
    t.bigint "card_id", null: false
    t.bigint "want_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["card_id"], name: "index_matches_on_card_id"
    t.index ["want_id"], name: "index_matches_on_want_id"
  end

  create_table "messages", force: :cascade do |t|
    t.string "content"
    t.bigint "user_id", null: false
    t.bigint "chatroom_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["chatroom_id"], name: "index_messages_on_chatroom_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "trades", force: :cascade do |t|
    t.string "status"
    t.bigint "user_id", null: false
    t.integer "user_id_invit"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_trades_on_user_id"
  end

  create_table "user_cards", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "card_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["card_id"], name: "index_user_cards_on_card_id"
    t.index ["user_id"], name: "index_user_cards_on_user_id"
  end

  create_table "user_wanted_cards", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "card_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["card_id"], name: "index_user_wanted_cards_on_card_id"
    t.index ["user_id"], name: "index_user_wanted_cards_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "username"
    t.float "latitude"
    t.float "longitude"
    t.string "address"
    t.integer "area"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "wants", force: :cascade do |t|
    t.string "name"
    t.integer "quantity"
    t.string "extension"
    t.string "min_cond"
    t.boolean "foil"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "language"
    t.bigint "image_id"
    t.index ["image_id"], name: "index_wants_on_image_id"
    t.index ["user_id"], name: "index_wants_on_user_id"
  end

  add_foreign_key "card_trades", "cards"
  add_foreign_key "card_trades", "trades"
  add_foreign_key "cards", "images"
  add_foreign_key "cards", "users"
  add_foreign_key "chatrooms", "users"
  add_foreign_key "matches", "cards"
  add_foreign_key "matches", "wants"
  add_foreign_key "messages", "chatrooms"
  add_foreign_key "messages", "users"
  add_foreign_key "trades", "users"
  add_foreign_key "user_cards", "cards"
  add_foreign_key "user_cards", "users"
  add_foreign_key "user_wanted_cards", "cards"
  add_foreign_key "user_wanted_cards", "users"
  add_foreign_key "wants", "images"
  add_foreign_key "wants", "users"
end
