# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161019152046) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.string   "author_type"
    t.integer  "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
  end

  create_table "incidents", force: :cascade do |t|
    t.datetime "started_at"
    t.datetime "resolved_at"
    t.integer  "duration"
    t.string   "state"
    t.string   "title"
    t.integer  "incident_id"
    t.boolean  "review"
    t.date     "followup_on"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "category_id"
    t.datetime "chat_start"
    t.datetime "chat_end"
    t.datetime "timeline_start"
    t.datetime "last_sync"
    t.string   "trello_url"
    t.string   "google_doc_url"
    t.index ["category_id"], name: "index_incidents_on_category_id", using: :btree
    t.index ["last_sync"], name: "index_incidents_on_last_sync", using: :btree
    t.index ["timeline_start"], name: "index_incidents_on_timeline_start", using: :btree
  end

  create_table "incidents_responders", id: false, force: :cascade do |t|
    t.integer "incident_id"
    t.integer "user_id"
    t.index ["incident_id"], name: "index_incidents_responders_on_incident_id", using: :btree
    t.index ["user_id"], name: "index_incidents_responders_on_user_id", using: :btree
  end

  create_table "remediations", force: :cascade do |t|
    t.datetime "created_on"
    t.string   "description"
    t.boolean  "completed"
    t.string   "pull_request"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "retrospective_id"
    t.index ["retrospective_id"], name: "index_remediations_on_retrospective_id", using: :btree
  end

  create_table "retrospectives", force: :cascade do |t|
    t.datetime "created_on"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "incident_id"
    t.index ["incident_id"], name: "index_retrospectives_on_incident_id", using: :btree
  end

  create_table "timeline_entries", force: :cascade do |t|
    t.datetime "timestamp"
    t.integer  "user_id"
    t.integer  "incident_id"
    t.text     "message"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["incident_id"], name: "index_timeline_entries_on_incident_id", using: :btree
    t.index ["timestamp"], name: "index_timeline_entries_on_timestamp", using: :btree
    t.index ["user_id"], name: "index_timeline_entries_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.text     "email",                null: false
    t.text     "name"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.string   "handle"
    t.string   "trello_oauth_token"
    t.string   "trello_oauth_secret"
    t.string   "google_refresh_token"
    t.string   "google_auth_code"
    t.string   "slack_access_token"
    t.string   "slack_user_id"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["handle"], name: "index_users_on_handle", using: :btree
  end

end
