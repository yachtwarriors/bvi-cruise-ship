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

ActiveRecord::Schema[8.0].define(version: 2026_03_28_194805) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "app_configs", force: :cascade do |t|
    t.string "key", null: false
    t.string "value", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_app_configs_on_key", unique: true
  end

  create_table "crowd_snapshots", force: :cascade do |t|
    t.bigint "location_id", null: false
    t.date "snapshot_date", null: false
    t.integer "hour", null: false
    t.string "intensity", null: false
    t.integer "estimated_visitors", default: 0
    t.jsonb "contributing_ships", default: []
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id", "snapshot_date", "hour"], name: "idx_crowd_snapshots_unique", unique: true
    t.index ["location_id"], name: "index_crowd_snapshots_on_location_id"
    t.index ["snapshot_date"], name: "index_crowd_snapshots_on_snapshot_date"
  end

  create_table "crowd_thresholds", force: :cascade do |t|
    t.bigint "location_id", null: false
    t.integer "green_max", null: false
    t.integer "yellow_max", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_crowd_thresholds_on_location_id", unique: true
  end

  create_table "cruise_visits", force: :cascade do |t|
    t.bigint "port_id", null: false
    t.string "ship_name", null: false
    t.string "cruise_line"
    t.integer "passenger_capacity"
    t.datetime "arrival_at"
    t.datetime "departure_at"
    t.date "visit_date", null: false
    t.string "source"
    t.boolean "capacity_estimated", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["port_id"], name: "index_cruise_visits_on_port_id"
    t.index ["ship_name", "visit_date", "port_id"], name: "idx_cruise_visits_unique", unique: true
    t.index ["visit_date"], name: "index_cruise_visits_on_visit_date"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_locations_on_slug", unique: true
  end

  create_table "ports", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_ports_on_slug", unique: true
  end

  create_table "scrape_logs", force: :cascade do |t|
    t.string "source"
    t.string "status"
    t.integer "records_fetched"
    t.text "error_message"
    t.datetime "scraped_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.date "alert_start_date"
    t.date "alert_end_date"
    t.boolean "email_enabled", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false, null: false
    t.index ["alert_start_date", "alert_end_date"], name: "index_users_on_alert_start_date_and_alert_end_date"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "crowd_snapshots", "locations"
  add_foreign_key "crowd_thresholds", "locations"
  add_foreign_key "cruise_visits", "ports"
end
