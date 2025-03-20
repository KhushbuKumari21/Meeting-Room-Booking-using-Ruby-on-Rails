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

ActiveRecord::Schema[8.0].define(version: 2025_03_16_161250) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gist"
  enable_extension "pg_catalog.plpgsql"

  create_table "admins", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bookings", id: :serial, force: :cascade do |t|
    t.integer "room_id"
    t.string "user_name", limit: 100, null: false
    t.timestamptz "start_time", null: false
    t.timestamptz "end_time", null: false
    t.bigint "meeting_room_id"
    t.bigint "user_id", null: false
    t.string "status"
    t.index ["meeting_room_id"], name: "index_bookings_on_meeting_room_id"
    t.index ["user_id"], name: "index_bookings_on_user_id"
    t.exclusion_constraint "room_id WITH =, tstzrange(start_time, end_time, '[]'::text) WITH &&", using: :gist, name: "no_overlap"
  end

  create_table "meeting_rooms", force: :cascade do |t|
    t.string "name"
    t.integer "capacity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "available"
  end

  create_table "rooms", id: :serial, force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.integer "capacity", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0
    t.string "name"
    t.boolean "admin"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "bookings", "meeting_rooms"
  add_foreign_key "bookings", "rooms", name: "bookings_room_id_fkey", on_delete: :cascade
  add_foreign_key "bookings", "users"
end
