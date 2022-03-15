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

ActiveRecord::Schema[7.0].define(version: 2022_03_15_151617) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "rooms", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name", null: false
    t.string "friendly_id", null: false
    t.string "meeting_id", null: false
    t.datetime "last_session"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["friendly_id"], name: "index_rooms_on_friendly_id", unique: true
    t.index ["meeting_id"], name: "index_rooms_on_meeting_id", unique: true
    t.index ["user_id"], name: "index_rooms_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "external_id"
    t.string "provider", null: false
    t.string "password_digest"
    t.datetime "last_login"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email", "provider"], name: "index_users_on_email_and_provider", unique: true
  end

  add_foreign_key "rooms", "users"
end
