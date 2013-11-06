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

ActiveRecord::Schema.define(:version => 20131106165431) do

  create_table "announcements", :force => true do |t|
    t.text      "body"
    t.string    "type"
    t.timestamp "created_at", :null => false
    t.timestamp "updated_at", :null => false
  end

  create_table "arenas", :force => true do |t|
    t.timestamp "created_at",                    :null => false
    t.timestamp "updated_at",                    :null => false
    t.integer   "user_id"
    t.string    "userclass",  :default => "N/A"
    t.string    "oppclass",   :default => "N/A"
    t.boolean   "win",        :default => false
    t.boolean   "gofirst",    :default => true
  end

  create_table "constructeds", :force => true do |t|
    t.timestamp "created_at",                    :null => false
    t.timestamp "updated_at",                    :null => false
    t.integer   "user_id"
    t.string    "deckname"
    t.string    "oppclass",   :default => "N/A"
    t.boolean   "win",        :default => false
    t.boolean   "gofirst",    :default => true
    t.integer   "deck_id"
  end

  create_table "decks", :force => true do |t|
    t.string    "name"
    t.integer   "wins",       :default => 0
    t.integer   "loses",      :default => 0
    t.timestamp "created_at",                :null => false
    t.timestamp "updated_at",                :null => false
    t.string    "race"
    t.integer   "user_id"
  end

  create_table "users", :force => true do |t|
    t.string    "email",                  :default => "", :null => false
    t.string    "encrypted_password",     :default => "", :null => false
    t.string    "reset_password_token"
    t.timestamp "reset_password_sent_at"
    t.timestamp "remember_created_at"
    t.integer   "sign_in_count",          :default => 0,  :null => false
    t.timestamp "current_sign_in_at"
    t.timestamp "last_sign_in_at"
    t.string    "current_sign_in_ip"
    t.string    "last_sign_in_ip"
    t.timestamp "created_at",                             :null => false
    t.timestamp "updated_at",                             :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
