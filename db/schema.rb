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

ActiveRecord::Schema.define(:version => 20110519143339) do

  create_table "comments", :force => true do |t|
    t.string   "title"
    t.text     "comment"
    t.integer  "user_id"
    t.integer  "video_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "uid"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.integer  "twitter_id"
    t.string   "twitter_token"
    t.string   "twitter_handle"
    t.string   "twitter_url"
    t.string   "twitter_profile_image_url"
    t.string   "oauth_token"
    t.string   "oauth_token_secret"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token",                        :null => false
    t.string   "single_access_token",                      :null => false
    t.string   "perishable_token",                         :null => false
    t.integer  "login_count",               :default => 0, :null => false
    t.integer  "failed_login_count",        :default => 0, :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "videos", :force => true do |t|
    t.string   "uid"
    t.string   "framey_name"
    t.string   "framey_video_url"
    t.string   "framey_thumbnail_url", :default => "http://framey.com/images/thumb_placeholder.png"
    t.integer  "views",                :default => 0
    t.integer  "likes",                :default => 0
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "twitter_text"
    t.string   "title"
    t.string   "short_link"
  end

end
