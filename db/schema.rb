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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150516131745) do

  create_table "entrants", force: :cascade do |t|
    t.integer  "player_id"
    t.integer  "tourney_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "entrants", ["player_id", "tourney_id"], name: "index_entrants_on_player_id_and_tourney_id", unique: true
  add_index "entrants", ["player_id"], name: "index_entrants_on_player_id"
  add_index "entrants", ["tourney_id"], name: "index_entrants_on_tourney_id"

  create_table "matches", force: :cascade do |t|
    t.integer  "player1_id"
    t.integer  "player2_id"
    t.integer  "tourney_id"
    t.integer  "round"
    t.integer  "player1_score"
    t.integer  "player2_score"
    t.integer  "ties"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.boolean  "bye"
  end

  create_table "players", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: hrfalse
  end

  create_table "tourneys", force: :cascade do |t|
    t.string   "name"
    t.datetime "date"
    t.string   "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "user_id"
    t.integer  "points_win"
    t.integer  "points_tie"
    t.integer  "points_bye"
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "admin",                  default: false
    t.string   "provider"
    t.string   "uid"
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["name"], name: "index_users_on_name", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
