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

ActiveRecord::Schema.define(:version => 20140311102310) do

  create_table "apps", :force => true do |t|
    t.string   "name"
    t.string   "auth_token"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "user_id"
  end

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
    t.integer  "evmethod_id"
    t.integer  "suitability"
  end

  create_table "evaluations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "assignment_id"
    t.integer  "lo_id"
    t.integer  "evmethod_id"
    t.string   "type"
    t.datetime "completed_at"
    t.integer  "item1"
    t.integer  "item2"
    t.integer  "item3"
    t.integer  "item4"
    t.integer  "item5"
    t.integer  "item6"
    t.integer  "item7"
    t.integer  "item8"
    t.integer  "item9"
    t.integer  "item10"
    t.integer  "item11"
    t.integer  "item12"
    t.integer  "item13"
    t.integer  "item14"
    t.integer  "item15"
    t.integer  "item16"
    t.integer  "item17"
    t.integer  "item18"
    t.integer  "item19"
    t.integer  "item20"
    t.integer  "item21"
    t.integer  "item22"
    t.integer  "item23"
    t.integer  "item24"
    t.integer  "item25"
    t.text     "comments"
    t.text     "titem1"
    t.text     "titem2"
    t.text     "titem3"
    t.text     "titem4"
    t.text     "titem5"
    t.text     "titem6"
    t.text     "titem7"
    t.text     "titem8"
    t.text     "titem9"
    t.text     "titem10"
    t.string   "sitem1"
    t.string   "sitem2"
    t.string   "sitem3"
    t.string   "sitem4"
    t.string   "sitem5"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.integer  "item26"
    t.integer  "item27"
    t.integer  "item28"
    t.integer  "item29"
    t.integer  "item30"
    t.integer  "item31"
    t.integer  "item32"
    t.integer  "item33"
    t.integer  "item34"
    t.integer  "item35"
    t.integer  "item36"
    t.integer  "item37"
    t.integer  "item38"
    t.integer  "item39"
    t.integer  "item40"
    t.text     "titem11"
    t.text     "titem12"
    t.text     "titem13"
    t.text     "titem14"
    t.text     "titem15"
    t.text     "titem16"
    t.text     "titem17"
    t.text     "titem18"
    t.text     "titem19"
    t.text     "titem20"
    t.text     "titem21"
    t.text     "titem22"
    t.text     "titem23"
    t.text     "titem24"
    t.text     "titem25"
    t.text     "titem26"
    t.text     "titem27"
    t.text     "titem28"
    t.text     "titem29"
    t.text     "titem30"
    t.text     "titem31"
    t.text     "titem32"
    t.text     "titem33"
    t.text     "titem34"
    t.text     "titem35"
    t.text     "titem36"
    t.text     "titem37"
    t.text     "titem38"
    t.text     "titem39"
    t.text     "titem40"
    t.decimal  "score",         :precision => 12, :scale => 6
  end

  create_table "evmethods", :force => true do |t|
    t.string   "name"
    t.string   "module"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.boolean  "allow_multiple_evaluations", :default => false
  end

  create_table "evmethods_metrics", :id => false, :force => true do |t|
    t.integer "evmethod_id"
    t.integer "metric_id"
  end

  create_table "languages", :force => true do |t|
    t.string   "name"
    t.string   "shortname"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "languages_users", :id => false, :force => true do |t|
    t.integer "language_id"
    t.integer "user_id"
  end

  create_table "lorics", :force => true do |t|
    t.integer  "user_id"
    t.integer  "item1"
    t.integer  "item2"
    t.integer  "item3"
    t.integer  "item4"
    t.integer  "item5"
    t.integer  "item6"
    t.integer  "item7"
    t.integer  "item8"
    t.integer  "item9"
    t.text     "comments"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "los", :force => true do |t|
    t.text     "url",               :limit => 16777215
    t.string   "name"
    t.text     "description",       :limit => 16777215
    t.string   "lotype"
    t.string   "repository"
    t.text     "callback",          :limit => 16777215
    t.string   "technology"
    t.text     "categories",        :limit => 16777215
    t.integer  "language_id"
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
    t.datetime "created_at",                                                   :null => false
    t.datetime "updated_at",                                                   :null => false
    t.string   "scope",                                 :default => "private"
  end

  create_table "metrics", :force => true do |t|
    t.string   "name"
    t.string   "type"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "metrics_evmethods", :id => false, :force => true do |t|
    t.integer "metric_id"
    t.integer "evmethod_id"
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

  create_table "scores", :force => true do |t|
    t.decimal  "value",      :precision => 12, :scale => 6
    t.integer  "metric_id"
    t.integer  "lo_id"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
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
    t.string   "email",                  :default => "",          :null => false
    t.string   "encrypted_password",     :default => "",          :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0,           :null => false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.string   "name"
    t.datetime "birthday"
    t.integer  "gender"
    t.integer  "language_id"
    t.integer  "loric_id"
    t.string   "occupation",             :default => "Education"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "users_languages", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "language_id"
  end

end
