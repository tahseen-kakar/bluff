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

ActiveRecord::Schema[8.0].define(version: 2024_12_22_142736) do
  create_table "game_formats", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.decimal "buy_in", precision: 10, scale: 2, null: false
    t.json "denominations", default: [], null: false
    t.integer "table_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["table_id", "name"], name: "index_game_formats_on_table_id_and_name", unique: true
    t.index ["table_id"], name: "index_game_formats_on_table_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "name", null: false
    t.text "notes"
    t.integer "table_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "emoji"
    t.decimal "wallet_balance", precision: 10, scale: 2, default: "0.0", null: false
    t.index ["table_id", "name"], name: "index_players_on_table_id_and_name", unique: true
    t.index ["table_id"], name: "index_players_on_table_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "tables", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_tables_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.string "username", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "game_formats", "tables"
  add_foreign_key "players", "tables"
  add_foreign_key "sessions", "users"
  add_foreign_key "tables", "users"
end
