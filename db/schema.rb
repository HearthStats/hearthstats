# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140126222959) do

  create_table "announcements", :force => true do |t|
    t.text      "body"
    t.string    "type"
    t.timestamp "created_at", :null => false
    t.timestamp "updated_at", :null => false
  end

  create_table "arena_runs", :force => true do |t|
    t.integer  "user_id"
    t.string   "userclass"
    t.integer  "gold",       :default => 0
    t.integer  "dust",       :default => 0
    t.boolean  "complete",   :default => false
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.text     "notes"
    t.string   "patch",      :default => "current"
  end

  add_index "arena_runs", ["user_id"], :name => "index_arena_runs_on_user_id"

  create_table "arenas", :force => true do |t|
    t.timestamp "created_at",                      :null => false
    t.timestamp "updated_at",                      :null => false
    t.integer   "user_id"
    t.string    "userclass",    :default => "N/A"
    t.string    "oppclass",     :default => "N/A"
    t.boolean   "win",          :default => false
    t.boolean   "gofirst",      :default => true
    t.integer   "arena_run_id"
    t.text      "notes"
    t.string    "oppname"
  end

  add_index "arenas", ["arena_run_id"], :name => "index_arenas_on_arena_run_id"
  add_index "arenas", ["user_id"], :name => "index_arenas_on_user_id"

  create_table "constructeds", :force => true do |t|
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.integer  "user_id"
    t.string   "deckname"
    t.string   "oppclass",   :default => "N/A"
    t.boolean  "win",        :default => false
    t.boolean  "gofirst",    :default => true
    t.integer  "deck_id"
    t.text     "notes"
    t.string   "rank",       :default => "Casual"
    t.string   "patch",      :default => "current"
    t.string   "oppname"
    t.integer  "ranklvl"
    t.integer  "legendary"
  end

  add_index "constructeds", ["deck_id"], :name => "index_constructeds_on_deck_id"
  add_index "constructeds", ["user_id"], :name => "index_constructeds_on_user_id"

  create_table "decks", :force => true do |t|
    t.string    "name"
    t.integer   "wins",       :default => 0
    t.integer   "loses",      :default => 0
    t.timestamp "created_at",                :null => false
    t.timestamp "updated_at",                :null => false
    t.string    "race"
    t.integer   "user_id"
    t.string    "decklink"
    t.string    "slug"
    t.text      "notes"
    t.integer   "slot"
    t.boolean   "active"
  end

  add_index "decks", ["slug"], :name => "index_decks_on_slug"
  add_index "decks", ["user_id"], :name => "index_decks_on_user_id"

  create_table "impressions", :force => true do |t|
    t.string    "impressionable_type"
    t.integer   "impressionable_id"
    t.integer   "user_id"
    t.string    "controller_name"
    t.string    "action_name"
    t.string    "view_name"
    t.string    "request_hash"
    t.string    "ip_address"
    t.string    "session_hash"
    t.text      "message"
    t.text      "referrer"
    t.timestamp "created_at",          :null => false
    t.timestamp "updated_at",          :null => false
  end

  add_index "impressions", ["controller_name", "action_name", "ip_address"], :name => "controlleraction_ip_index"
  add_index "impressions", ["controller_name", "action_name", "request_hash"], :name => "controlleraction_request_index"
  add_index "impressions", ["controller_name", "action_name", "session_hash"], :name => "controlleraction_session_index"
  add_index "impressions", ["impressionable_type", "impressionable_id", "ip_address"], :name => "poly_ip_index"
  add_index "impressions", ["impressionable_type", "impressionable_id", "request_hash"], :name => "poly_request_index"
  add_index "impressions", ["impressionable_type", "impressionable_id", "session_hash"], :name => "poly_session_index"
  add_index "impressions", ["user_id"], :name => "index_impressions_on_user_id"

  create_table "profiles", :force => true do |t|
    t.string   "name"
    t.string   "bnetid"
    t.boolean  "private",    :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.integer  "user_id"
    t.integer  "bnetnum",    :default => 0
    t.string   "time_zone",  :default => "EST"
  end

  add_index "profiles", ["user_id"], :name => "index_profiles_on_user_id"

  create_table "redactor_assets", :force => true do |t|
    t.integer  "user_id"
    t.string   "data_file_name",                  :null => false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    :limit => 30
    t.string   "type",              :limit => 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "redactor_assets", ["assetable_type", "assetable_id"], :name => "idx_redactor_assetable"
  add_index "redactor_assets", ["assetable_type", "type", "assetable_id"], :name => "idx_redactor_assetable_type"

  create_table "tournies", :force => true do |t|
    t.integer  "challonge_id"
    t.integer  "status",       :default => 0
    t.integer  "winner_id"
    t.string   "prize"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.boolean  "complete",     :default => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                 :null => false
    t.string   "encrypted_password",                    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0, :null => false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.integer  "tourny_id"
    t.boolean  "guest"
    t.string   "userkey"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["tourny_id"], :name => "index_users_on_tourny_id"

end
