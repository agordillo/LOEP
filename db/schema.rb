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

ActiveRecord::Schema.define(:version => 20140901124007) do

  create_table "apps", :force => true do |t|
    t.string   "name"
    t.string   "auth_token"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "user_id"
    t.text     "callback",   :limit => 16777215
  end

  create_table "assignments", :force => true do |t|
    t.integer  "author_id"
    t.integer  "user_id"
    t.integer  "lo_id"
    t.string   "status"
    t.datetime "deadline"
    t.datetime "completed_at"
    t.text     "description",  :limit => 16777215
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.integer  "evmethod_id"
    t.integer  "suitability"
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
    t.text     "comments",      :limit => 16777215
    t.text     "titem1",        :limit => 16777215
    t.text     "titem2",        :limit => 16777215
    t.text     "titem3",        :limit => 16777215
    t.text     "titem4",        :limit => 16777215
    t.text     "titem5",        :limit => 16777215
    t.text     "titem6",        :limit => 16777215
    t.text     "titem7",        :limit => 16777215
    t.text     "titem8",        :limit => 16777215
    t.text     "titem9",        :limit => 16777215
    t.text     "titem10",       :limit => 16777215
    t.string   "sitem1"
    t.string   "sitem2"
    t.string   "sitem3"
    t.string   "sitem4"
    t.string   "sitem5"
    t.datetime "created_at",                                                       :null => false
    t.datetime "updated_at",                                                       :null => false
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
    t.text     "titem11",       :limit => 16777215
    t.text     "titem12",       :limit => 16777215
    t.text     "titem13",       :limit => 16777215
    t.text     "titem14",       :limit => 16777215
    t.text     "titem15",       :limit => 16777215
    t.text     "titem16",       :limit => 16777215
    t.text     "titem17",       :limit => 16777215
    t.text     "titem18",       :limit => 16777215
    t.text     "titem19",       :limit => 16777215
    t.text     "titem20",       :limit => 16777215
    t.text     "titem21",       :limit => 16777215
    t.text     "titem22",       :limit => 16777215
    t.text     "titem23",       :limit => 16777215
    t.text     "titem24",       :limit => 16777215
    t.text     "titem25",       :limit => 16777215
    t.text     "titem26",       :limit => 16777215
    t.text     "titem27",       :limit => 16777215
    t.text     "titem28",       :limit => 16777215
    t.text     "titem29",       :limit => 16777215
    t.text     "titem30",       :limit => 16777215
    t.text     "titem31",       :limit => 16777215
    t.text     "titem32",       :limit => 16777215
    t.text     "titem33",       :limit => 16777215
    t.text     "titem34",       :limit => 16777215
    t.text     "titem35",       :limit => 16777215
    t.text     "titem36",       :limit => 16777215
    t.text     "titem37",       :limit => 16777215
    t.text     "titem38",       :limit => 16777215
    t.text     "titem39",       :limit => 16777215
    t.text     "titem40",       :limit => 16777215
    t.decimal  "score",                             :precision => 12, :scale => 6
    t.integer  "item41"
    t.integer  "item42"
    t.integer  "item43"
    t.integer  "item44"
    t.integer  "item45"
    t.integer  "item46"
    t.integer  "item47"
    t.integer  "item48"
    t.integer  "item49"
    t.integer  "item50"
    t.integer  "item51"
    t.integer  "item52"
    t.integer  "item53"
    t.integer  "item54"
    t.integer  "item55"
    t.integer  "item56"
    t.integer  "item57"
    t.integer  "item58"
    t.integer  "item59"
    t.integer  "item60"
    t.integer  "item61"
    t.integer  "item62"
    t.integer  "item63"
    t.integer  "item64"
    t.integer  "item65"
    t.integer  "item66"
    t.integer  "item67"
    t.integer  "item68"
    t.integer  "item69"
    t.integer  "item70"
    t.integer  "item71"
    t.integer  "item72"
    t.integer  "item73"
    t.integer  "item74"
    t.integer  "item75"
    t.integer  "item76"
    t.integer  "item77"
    t.integer  "item78"
    t.integer  "item79"
    t.integer  "item80"
    t.integer  "item81"
    t.integer  "item82"
    t.integer  "item83"
    t.integer  "item84"
    t.integer  "item85"
    t.integer  "item86"
    t.integer  "item87"
    t.integer  "item88"
    t.integer  "item89"
    t.integer  "item90"
    t.integer  "item91"
    t.integer  "item92"
    t.integer  "item93"
    t.integer  "item94"
    t.integer  "item95"
    t.integer  "item96"
    t.integer  "item97"
    t.integer  "item98"
    t.integer  "item99"
  end

  create_table "evmethods", :force => true do |t|
    t.string   "name"
    t.string   "module"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.boolean  "allow_multiple_evaluations", :default => false
  end

  create_table "evmethods_assignments", :id => false, :force => true do |t|
    t.integer "evmethod_id"
    t.integer "assignment_id"
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
    t.string   "scope",                                 :default => "Private"
    t.integer  "owner_id"
    t.integer  "app_id"
    t.integer  "id_repository"
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

  create_table "survey_ranking_as", :force => true do |t|
    t.text     "results"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
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
