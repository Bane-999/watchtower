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

ActiveRecord::Schema[7.1].define(version: 2025_12_11_120000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "watchtower_incidents", force: :cascade do |t|
    t.string "exception_class", null: false
    t.string "exception_message", null: false
    t.text "backtrace"
    t.string "fingerprint", null: false
    t.string "severity", default: "medium", null: false
    t.string "status", default: "open", null: false
    t.string "actor_type"
    t.bigint "actor_id"
    t.string "request_url"
    t.string "request_method"
    t.string "controller"
    t.string "action"
    t.inet "ip_address"
    t.string "user_agent"
    t.jsonb "params", default: {}, null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "occurred_at", null: false
    t.datetime "resolved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_type", "actor_id"], name: "index_watchtower_incidents_on_actor_type_and_actor_id"
    t.index ["fingerprint"], name: "index_watchtower_incidents_on_fingerprint"
    t.index ["metadata"], name: "index_watchtower_incidents_on_metadata", using: :gin
    t.index ["occurred_at"], name: "index_watchtower_incidents_on_occurred_at"
    t.index ["params"], name: "index_watchtower_incidents_on_params", using: :gin
    t.index ["severity"], name: "index_watchtower_incidents_on_severity"
    t.index ["status"], name: "index_watchtower_incidents_on_status"
  end

end
