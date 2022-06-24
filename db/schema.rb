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

ActiveRecord::Schema[7.0].define(version: 2022_06_16_175700) do
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

  create_table "data_migrations", primary_key: "version", id: :string, force: :cascade do |t|
  end

  create_table "formats", force: :cascade do |t|
    t.bigint "recording_id"
    t.string "recording_type", null: false
    t.string "url", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recording_id"], name: "index_formats_on_recording_id"
  end

  create_table "meeting_options", force: :cascade do |t|
    t.string "name"
    t.string "default_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_meeting_options_on_name", unique: true
  end

  create_table "recordings", force: :cascade do |t|
    t.bigint "room_id"
    t.string "name", null: false
    t.string "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "visibility", null: false
    t.integer "length", null: false
    t.integer "users", null: false
    t.index ["room_id"], name: "index_recordings_on_room_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name", null: false
    t.string "color", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "room_meeting_options", force: :cascade do |t|
    t.bigint "room_id"
    t.bigint "meeting_option_id"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["meeting_option_id"], name: "index_room_meeting_options_on_meeting_option_id"
    t.index ["room_id"], name: "index_room_meeting_options_on_room_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name", null: false
    t.string "friendly_id", null: false
    t.string "meeting_id", null: false
    t.datetime "last_session"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "viewer_access_code"
    t.string "moderator_access_code"
    t.integer "recordings_processing", default: 0
    t.index ["friendly_id"], name: "index_rooms_on_friendly_id", unique: true
    t.index ["meeting_id"], name: "index_rooms_on_meeting_id", unique: true
    t.index ["user_id"], name: "index_rooms_on_user_id"
  end

  create_table "shared_accesses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "room_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["room_id"], name: "index_shared_accesses_on_room_id"
    t.index ["user_id", "room_id"], name: "index_shared_accesses_on_user_id_and_room_id", unique: true
    t.index ["user_id"], name: "index_shared_accesses_on_user_id"
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
    t.bigint "role_id"
    t.string "language", null: false
    t.string "reset_digest"
    t.datetime "reset_sent_at", precision: nil
    t.boolean "active", default: false
    t.string "activation_digest"
    t.datetime "activation_sent_at", precision: nil
    t.index ["activation_digest"], name: "index_users_on_activation_digest", unique: true
    t.index ["email", "provider"], name: "index_users_on_email_and_provider", unique: true
    t.index ["reset_digest"], name: "index_users_on_reset_digest", unique: true
    t.index ["role_id"], name: "index_users_on_role_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "formats", "recordings"
  add_foreign_key "recordings", "rooms"
  add_foreign_key "room_meeting_options", "meeting_options"
  add_foreign_key "room_meeting_options", "rooms"
  add_foreign_key "rooms", "users"
  add_foreign_key "shared_accesses", "rooms"
  add_foreign_key "shared_accesses", "users"
  add_foreign_key "users", "roles"
end
