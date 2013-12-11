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

ActiveRecord::Schema.define(:version => 20131211143248) do

  create_table "assignments", :force => true do |t|
    t.integer  "author_id"
    t.integer  "user_id"
    t.integer  "lo_id"
    t.string   "status"
    t.datetime "deadline"
    t.datetime "completed_at"
    t.text     "description"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "assignments_evmethods", :id => false, :force => true do |t|
    t.integer "assignment_id"
    t.integer "evmethod_id"
  end

  create_table "evaluations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "assignment_id"
    t.integer  "lo_id"
    t.integer  "evmethod_id"
    t.datetime "completed_at"
    t.string   "type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "evmethods", :force => true do |t|
    t.string   "name"
    t.string   "module"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "evmethods_assignments", :id => false, :force => true do |t|
    t.integer "evmethod_id"
    t.integer "assignment_id"
  end

  create_table "los", :force => true do |t|
    t.text     "url"
    t.string   "name"
    t.text     "description"
    t.string   "lotype"
    t.string   "repository"
    t.text     "callback"
    t.string   "technology"
    t.text     "categories"
    t.string   "lan"
    t.boolean  "hasText"
    t.boolean  "hasImages"
    t.boolean  "hasVideos"
    t.boolean  "hasAudios"
    t.boolean  "hasQuizzes"
    t.boolean  "hasWebs"
    t.boolean  "hasFlashObjects"
    t.boolean  "hasApplets"
    t.boolean  "hasDocuments"
    t.boolean  "hasFlashcards"
    t.boolean  "hasVirtualTours"
    t.boolean  "hasEnrichedVideos"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
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

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "users", :force => true do |t|
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
    t.string   "name"
    t.datetime "birthday"
    t.integer  "gender"
    t.string   "lan"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
