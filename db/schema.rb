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

ActiveRecord::Schema[7.1].define(version: 2025_07_14_073418) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "checklist_items", force: :cascade do |t|
    t.bigint "trip_id", null: false
    t.bigint "item_id", null: false
    t.string "name"
    t.boolean "checked"
    t.jsonb "anything"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_checklist_items_on_item_id"
    t.index ["trip_id"], name: "index_checklist_items_on_trip_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "name"
    t.string "category"
    t.boolean "default"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trips", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.string "destination"
    t.string "country"
    t.float "latitude"
    t.float "longitude"
    t.date "start_date"
    t.date "end_date"
    t.boolean "public"
    t.jsonb "weather_data"
    t.jsonb "accommodation_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_trips_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "email"
    t.string "encrypted_password"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "checklist_items", "items"
  add_foreign_key "checklist_items", "trips"
  add_foreign_key "trips", "users"
end
