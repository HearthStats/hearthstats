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

ActiveRecord::Schema.define(:version => 20140731170706) do

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

  create_table "annoucements", :force => true do |t|
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

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

  create_table "arenas", :force => true do |t|
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "user_id"
    t.string   "userclass",    :default => "N/A"
    t.string   "oppclass",     :default => "N/A"
    t.boolean  "win",          :default => false
    t.boolean  "gofirst",      :default => true
    t.integer  "arena_run_id"
    t.text     "notes"
    t.string   "oppname"
  end

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
    t.integer "patch_id"
    t.string  "blizz_id"
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

  create_table "conversations", :force => true do |t|
    t.string   "subject",    :default => ""
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "deck_versions", :force => true do |t|
    t.integer  "deck_id"
    t.text     "notes"
    t.integer  "version"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "cardstring"
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

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0, :null => false
    t.integer  "attempts",   :default => 0, :null => false
    t.text     "handler",                   :null => false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "impressions", :force => true do |t|
    t.string   "impressionable_type"
    t.integer  "impressionable_id"
    t.integer  "user_id"
    t.string   "controller_name"
    t.string   "action_name"
    t.string   "view_name"
    t.string   "request_hash"
    t.string   "ip_address"
    t.string   "session_hash"
    t.text     "message"
    t.text     "referrer"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "klasses", :force => true do |t|
    t.string "name"
  end

  create_table "match_decks", :force => true do |t|
    t.integer  "deck_id"
    t.integer  "match_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "match_ranks", :force => true do |t|
    t.integer  "rank_id"
    t.integer  "match_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "legendary"
  end

  create_table "match_results", :force => true do |t|
    t.integer  "match_id"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "match_runs", :force => true do |t|
    t.integer  "arena_run_id"
    t.integer  "match_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

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

  create_table "patches", :force => true do |t|
    t.string   "num"
    t.text     "changelog"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "profiles", :force => true do |t|
    t.string   "name"
    t.string   "bnetid"
    t.boolean  "private",              :default => false
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.integer  "user_id"
    t.integer  "bnetnum",              :default => 0
    t.string   "time_zone",            :default => "EST"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "locale",               :default => "en"
    t.string   "sig_pic_file_name"
    t.string   "sig_pic_content_type"
    t.integer  "sig_pic_file_size"
    t.datetime "sig_pic_updated_at"
  end

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

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "seasons", :force => true do |t|
    t.integer  "num"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "name"
  end

  create_table "shortened_urls", :force => true do |t|
    t.integer  "owner_id"
    t.string   "owner_type", :limit => 20
    t.string   "url",                                     :null => false
    t.string   "unique_key", :limit => 10,                :null => false
    t.integer  "use_count",                :default => 0, :null => false
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  add_index "shortened_urls", ["owner_id", "owner_type"], :name => "index_shortened_urls_on_owner_id_and_owner_type"
  add_index "shortened_urls", ["unique_key"], :name => "index_shortened_urls_on_unique_key", :unique => true
  add_index "shortened_urls", ["url"], :name => "index_shortened_urls_on_url"

  create_table "subscriptions", :force => true do |t|
    t.string "name"
    t.float  "cost"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :limit => 128
    t.datetime "created_at"
  end

  create_table "tags", :force => true do |t|
    t.string  "name"
    t.integer "taggings_count", :default => 0
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
    t.integer  "challonge_id"
    t.integer  "status",        :default => 0
    t.integer  "winner_id"
    t.string   "prize"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.boolean  "complete",      :default => false
    t.integer  "user_decks_id"
    t.string   "title"
    t.string   "desc"
    t.datetime "date"
    t.string   "pic_link"
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
    t.integer  "subscription_id"
    t.string   "authentication_token"
    t.string   "customer_id"
  end

  create_table "users_roles", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

end
