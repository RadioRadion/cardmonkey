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

ActiveRecord::Schema.define(version: 2020_06_29_130447) do

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
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_cards_on_user_id"
  end

  create_table "trades", force: :cascade do |t|
    t.string "status"
    t.bigint "user_id", null: false
    t.integer "user_id_invit"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_trades_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "wantlists", force: :cascade do |t|
    t.string "name"
    t.integer "quantity"
    t.string "extension"
    t.string "min_cond"
    t.boolean "foil"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_wantlists_on_user_id"
  end

  add_foreign_key "card_trades", "cards"
  add_foreign_key "card_trades", "trades"
  add_foreign_key "cards", "users"
  add_foreign_key "trades", "users"
  add_foreign_key "wantlists", "users"
end
