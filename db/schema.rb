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

ActiveRecord::Schema[7.1].define(version: 2023_12_18_154727) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
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

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "data_migrations", primary_key: "version", id: :string, force: :cascade do |t|
  end

  create_table "formats", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "recording_id"
    t.string "recording_type", null: false
    t.string "url", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recording_id"], name: "index_formats_on_recording_id"
  end

  create_table "invitations", force: :cascade do |t|
    t.string "email", null: false
    t.string "provider", null: false
    t.string "token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email", "provider"], name: "index_invitations_on_email_and_provider", unique: true
    t.index ["token"], name: "index_invitations_on_token", unique: true
  end

  create_table "meeting_options", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "default_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_meeting_options_on_name", unique: true
  end

  create_table "permissions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "recordings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "room_id"
    t.string "name", null: false
    t.string "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "visibility", null: false
    t.integer "length", null: false
    t.integer "participants", null: false
    t.boolean "protectable"
    t.datetime "recorded_at"
    t.index ["room_id"], name: "index_recordings_on_room_id"
  end

  create_table "role_permissions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "role_id"
    t.uuid "permission_id"
    t.string "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["permission_id"], name: "index_role_permissions_on_permission_id"
    t.index ["role_id"], name: "index_role_permissions_on_role_id"
  end

  create_table "roles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "color", default: "", null: false
    t.string "provider", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "provider"], name: "index_roles_on_name_and_provider", unique: true
  end

  create_table "room_meeting_options", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "room_id"
    t.uuid "meeting_option_id"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["meeting_option_id"], name: "index_room_meeting_options_on_meeting_option_id"
    t.index ["room_id"], name: "index_room_meeting_options_on_room_id"
  end

  create_table "rooms", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.string "name", null: false
    t.string "friendly_id", null: false
    t.string "meeting_id", null: false
    t.datetime "last_session"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "recordings_processing", default: 0
    t.boolean "online", default: false
    t.index ["friendly_id"], name: "index_rooms_on_friendly_id", unique: true
    t.index ["meeting_id"], name: "index_rooms_on_meeting_id", unique: true
    t.index ["user_id"], name: "index_rooms_on_user_id"
  end

  create_table "rooms_configurations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "meeting_option_id"
    t.string "provider", null: false
    t.string "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["meeting_option_id", "provider"], name: "index_rooms_configurations_on_meeting_option_id_and_provider", unique: true
    t.index ["meeting_option_id"], name: "index_rooms_configurations_on_meeting_option_id"
  end

  create_table "settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_settings_on_name", unique: true
  end

  create_table "shared_accesses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "room_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["room_id"], name: "index_shared_accesses_on_room_id"
    t.index ["user_id", "room_id"], name: "index_shared_accesses_on_user_id_and_room_id", unique: true
    t.index ["user_id"], name: "index_shared_accesses_on_user_id"
  end

  create_table "site_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "setting_id"
    t.string "value", null: false
    t.string "provider", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["setting_id"], name: "index_site_settings_on_setting_id"
  end

  create_table "tenants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "client_secret", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tenants_on_name", unique: true
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "external_id"
    t.string "provider", null: false
    t.string "password_digest"
    t.datetime "last_login"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "role_id"
    t.string "language", null: false
    t.string "reset_digest"
    t.datetime "reset_sent_at", precision: nil
    t.boolean "verified", default: false
    t.string "verification_digest"
    t.datetime "verification_sent_at", precision: nil
    t.string "session_token"
    t.datetime "session_expiry", precision: nil
    t.integer "status", default: 0
    t.boolean "confirm_terms", default: false
    t.boolean "email_notifs", default: false
    t.index ["email", "provider"], name: "index_users_on_email_and_provider", unique: true
    t.index ["reset_digest"], name: "index_users_on_reset_digest", unique: true
    t.index ["role_id"], name: "index_users_on_role_id"
    t.index ["session_token"], name: "index_users_on_session_token", unique: true
    t.index ["verification_digest"], name: "index_users_on_verification_digest", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "formats", "recordings"
  add_foreign_key "recordings", "rooms"
  add_foreign_key "role_permissions", "permissions"
  add_foreign_key "role_permissions", "roles"
  add_foreign_key "room_meeting_options", "meeting_options"
  add_foreign_key "room_meeting_options", "rooms"
  add_foreign_key "rooms", "users"
  add_foreign_key "rooms_configurations", "meeting_options"
  add_foreign_key "shared_accesses", "rooms"
  add_foreign_key "shared_accesses", "users"
  add_foreign_key "site_settings", "settings"
  add_foreign_key "users", "roles"
end
