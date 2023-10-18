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

ActiveRecord::Schema[7.0].define(version: 202310181616) do
  create_table "areas", force: :cascade do |t|
    t.integer "starting_room_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "items_items", force: :cascade do |t|
    t.string "type"
    t.string "name"
    t.string "description"
    t.integer "weight"
    t.integer "value"
    t.integer "holdable_id"
    t.string "holdable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "room_connections", force: :cascade do |t|
    t.integer "room_id"
    t.integer "destination_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "name"
  end

  create_table "rooms", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "title"
    t.string "description"
    t.string "room_type"
    t.integer "area_id"
    t.integer "x"
    t.integer "y"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "name"
    t.string "password"
    t.integer "room_id"
    t.integer "max_health"
    t.integer "max_mana"
    t.integer "current_health"
    t.integer "current_mana"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "online"
    t.boolean "superuser", default: false
  end

end
