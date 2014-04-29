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

ActiveRecord::Schema.define(:version => 20140429155445) do

  create_table "active_admin_comments", :force => true do |t|
    t.string   "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "admin_users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0,  :null => false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "admin_users", ["email"], :name => "index_admin_users_on_email", :unique => true
  add_index "admin_users", ["reset_password_token"], :name => "index_admin_users_on_reset_password_token", :unique => true

  create_table "arena_run_cards", :force => true do |t|
    t.integer  "arena_run_id"
    t.integer  "card_id"
    t.boolean  "golden"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "arena_runs", :force => true do |t|
    t.integer  "user_id"
    t.integer  "gold",       :default => 0
    t.integer  "dust",       :default => 0
    t.boolean  "complete",   :default => false
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.text     "notes"
    t.string   "patch",      :default => "current"
    t.integer  "klass_id"
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

  create_table "card_sets", :force => true do |t|
    t.string "name"
    t.text   "notes"
  end

  create_table "cards", :force => true do |t|
    t.string  "name"
    t.string  "description"
    t.integer "attack"
    t.integer "health"
    t.integer "card_set_id"
    t.integer "rarity_id"
    t.integer "type_id"
    t.integer "klass_id"
    t.integer "race_id"
    t.integer "mana"
    t.boolean "collectible"
    t.string  "image_link"
    t.integer "patch_id"
    t.integer "hearthhead_id"
  end

  create_table "coaches", :force => true do |t|
    t.integer  "user_id"
    t.text     "description"
    t.text     "available"
    t.boolean  "active",      :default => true
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "comments", :force => true do |t|
    t.integer  "owner_id",         :null => false
    t.integer  "commentable_id",   :null => false
    t.string   "commentable_type", :null => false
    t.text     "body",             :null => false
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "constructeds", :force => true do |t|
    t.timestamp "created_at",                        :null => false
    t.timestamp "updated_at",                        :null => false
    t.integer   "user_id"
    t.string    "deckname"
    t.string    "oppclass",   :default => "N/A"
    t.boolean   "win",        :default => false
    t.boolean   "gofirst",    :default => true
    t.integer   "deck_id"
    t.text      "notes"
    t.string    "rank",       :default => "Casual"
    t.string    "patch",      :default => "current"
    t.string    "oppname"
    t.integer   "ranklvl"
    t.integer   "legendary"
  end

  add_index "constructeds", ["deck_id"], :name => "index_constructeds_on_deck_id"
  add_index "constructeds", ["user_id"], :name => "index_constructeds_on_user_id"

  create_table "conversations", :force => true do |t|
    t.string   "subject",    :default => ""
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "deck_versions", :force => true do |t|
    t.integer  "deck_id"
    t.integer  "unique_deck_id"
    t.text     "notes"
    t.integer  "version",        :limit => 255
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "decks", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "user_id"
    t.string   "slug"
    t.text     "notes"
    t.integer  "slot"
    t.boolean  "active"
    t.integer  "klass_id"
    t.string   "cardstring"
    t.integer  "unique_deck_id"
    t.integer  "user_num_matches"
    t.integer  "user_num_wins"
    t.integer  "user_num_losses"
    t.float    "user_winrate"
    t.boolean  "is_public"
  end

  add_index "decks", ["klass_id"], :name => "index_decks_on_klass_id"
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

  create_table "klasses", :force => true do |t|
    t.string "name"
  end

  create_table "match_decks", :force => true do |t|
    t.integer  "deck_id"
    t.integer  "match_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "match_decks", ["deck_id"], :name => "index_match_decks_on_deck_id"
  add_index "match_decks", ["match_id"], :name => "index_match_decks_on_match_id"

  create_table "match_ranks", :force => true do |t|
    t.integer  "rank_id"
    t.integer  "match_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "match_ranks", ["match_id"], :name => "index_match_ranks_on_match_id"
  add_index "match_ranks", ["rank_id"], :name => "index_match_ranks_on_rank_id"

  create_table "match_results", :force => true do |t|
    t.integer  "match_id"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "match_results", ["match_id"], :name => "index_match_results_on_match_id"

  create_table "match_runs", :force => true do |t|
    t.integer  "arena_run_id"
    t.integer  "match_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "match_runs", ["arena_run_id"], :name => "index_match_runs_on_arena_run_id"
  add_index "match_runs", ["match_id"], :name => "index_match_runs_on_match_id"

  create_table "match_unique_decks", :force => true do |t|
    t.integer  "unique_deck_id"
    t.integer  "match_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "matches", :force => true do |t|
    t.integer  "user_id"
    t.integer  "klass_id"
    t.integer  "oppclass_id"
    t.string   "oppname"
    t.integer  "mode_id"
    t.integer  "result_id"
    t.text     "notes"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.boolean  "coin"
    t.integer  "numturns"
    t.integer  "duration"
    t.integer  "patch_id"
    t.integer  "season_id"
    t.boolean  "appsubmit"
  end

  add_index "matches", ["klass_id"], :name => "index_matches_on_klass_id"
  add_index "matches", ["mode_id"], :name => "index_matches_on_mode_id"
  add_index "matches", ["oppclass_id"], :name => "index_matches_on_oppclass_id"
  add_index "matches", ["result_id"], :name => "index_matches_on_result_id"
  add_index "matches", ["user_id"], :name => "index_matches_on_user_id"

  create_table "modes", :force => true do |t|
    t.string "name"
  end

  create_table "notifications", :force => true do |t|
    t.string   "type"
    t.text     "body"
    t.string   "subject",              :default => ""
    t.integer  "sender_id"
    t.string   "sender_type"
    t.integer  "conversation_id"
    t.boolean  "draft",                :default => false
    t.datetime "updated_at",                              :null => false
    t.datetime "created_at",                              :null => false
    t.integer  "notified_object_id"
    t.string   "notified_object_type"
    t.string   "notification_code"
    t.string   "attachment"
    t.boolean  "global",               :default => false
    t.datetime "expires"
  end

  add_index "notifications", ["conversation_id"], :name => "index_notifications_on_conversation_id"

  create_table "patches", :force => true do |t|
    t.string   "num"
    t.text     "changelog"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "profiles", :force => true do |t|
    t.string    "name"
    t.string    "bnetid"
    t.boolean   "private",             :default => false
    t.timestamp "created_at",                             :null => false
    t.timestamp "updated_at",                             :null => false
    t.integer   "user_id"
    t.integer   "bnetnum",             :default => 0
    t.string    "time_zone",           :default => "EST"
    t.string    "avatar_file_name"
    t.string    "avatar_content_type"
    t.integer   "avatar_file_size"
    t.datetime  "avatar_updated_at"
  end

  add_index "profiles", ["user_id"], :name => "index_profiles_on_user_id"

  create_table "races", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "ranks", :force => true do |t|
    t.string   "name"
    t.integer  "order"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "rarities", :force => true do |t|
    t.integer  "card_id"
    t.string   "rarity"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "receipts", :force => true do |t|
    t.integer  "receiver_id"
    t.string   "receiver_type"
    t.integer  "notification_id",                                  :null => false
    t.boolean  "is_read",                       :default => false
    t.boolean  "trashed",                       :default => false
    t.boolean  "deleted",                       :default => false
    t.string   "mailbox_type",    :limit => 25
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
  end

  add_index "receipts", ["notification_id"], :name => "index_receipts_on_notification_id"

  create_table "redactor_assets", :force => true do |t|
    t.integer   "user_id"
    t.string    "data_file_name",                  :null => false
    t.string    "data_content_type"
    t.integer   "data_file_size"
    t.integer   "assetable_id"
    t.string    "assetable_type",    :limit => 30
    t.string    "type",              :limit => 30
    t.integer   "width"
    t.integer   "height"
    t.timestamp "created_at",                      :null => false
    t.timestamp "updated_at",                      :null => false
  end

  add_index "redactor_assets", ["assetable_type", "assetable_id"], :name => "idx_redactor_assetable"
  add_index "redactor_assets", ["assetable_type", "type", "assetable_id"], :name => "idx_redactor_assetable_type"

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "roles", ["name", "resource_type", "resource_id"], :name => "index_roles_on_name_and_resource_type_and_resource_id"
  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "seasons", :force => true do |t|
    t.integer  "num"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "subscriptions", :force => true do |t|
    t.string "name"
    t.float  "cost"
  end

  create_table "team_users", :force => true do |t|
    t.integer "user_id"
    t.integer "team_id"
  end

  create_table "teams", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "tournies", :force => true do |t|
    t.integer   "challonge_id"
    t.integer   "status",       :default => 0
    t.integer   "winner_id"
    t.string    "prize"
    t.timestamp "created_at",                      :null => false
    t.timestamp "updated_at",                      :null => false
    t.boolean   "complete",     :default => false
  end

  create_table "types", :force => true do |t|
    t.string "name"
  end

  create_table "unique_deck_cards", :force => true do |t|
    t.integer  "unique_deck_id"
    t.integer  "card_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "unique_decks", :force => true do |t|
    t.string   "cardstring"
    t.integer  "klass_id"
    t.integer  "num_matches"
    t.integer  "num_wins"
    t.integer  "num_losses"
    t.integer  "num_minions"
    t.integer  "num_spells"
    t.integer  "num_weapons"
    t.datetime "last_played"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.float    "winrate"
    t.integer  "num_users"
  end

  create_table "users", :force => true do |t|
    t.string    "email",                                 :null => false
    t.string    "encrypted_password",                    :null => false
    t.string    "reset_password_token"
    t.timestamp "reset_password_sent_at"
    t.timestamp "remember_created_at"
    t.integer   "sign_in_count",          :default => 0, :null => false
    t.timestamp "current_sign_in_at"
    t.timestamp "last_sign_in_at"
    t.string    "current_sign_in_ip"
    t.string    "last_sign_in_ip"
    t.timestamp "created_at",                            :null => false
    t.timestamp "updated_at",                            :null => false
    t.integer   "tourny_id"
    t.boolean   "guest"
    t.string    "userkey"
    t.integer   "subscription_id"
    t.string    "authentication_token"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["tourny_id"], :name => "index_users_on_tourny_id"

  create_table "users_roles", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], :name => "index_users_roles_on_user_id_and_role_id"

end
