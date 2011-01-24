# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20101130102446) do

  create_table "announcements", :force => true do |t|
    t.string   "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "artworks", :force => true do |t|
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.integer  "person_id"
    t.integer  "attachable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "attachable_type",       :default => "Competition"
  end

  create_table "bids", :force => true do |t|
    t.string   "name"
    t.decimal  "price",             :precision => 9, :scale => 2
    t.text     "brief"
    t.text     "capabilities"
    t.text     "offered_services"
    t.text     "terms_of_service"
    t.text     "warranties"
    t.integer  "person_id"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "won"
    t.string   "data_file_name"
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.datetime "data_updated_at"
  end

  create_table "blog_images", :force => true do |t|
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "buries", :force => true do |t|
    t.integer  "person_id"
    t.integer  "comment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.integer  "rating"
    t.text     "body"
    t.integer  "person_id"
    t.integer  "commentable_id"
    t.string   "commentable_type", :default => "Logo"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "buries_count"
    t.boolean  "delta",            :default => true,   :null => false
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["commentable_type"], :name => "index_comments_on_commentable_type"
  add_index "comments", ["delta"], :name => "index_comments_on_delta"
  add_index "comments", ["person_id"], :name => "index_comments_on_person_id"
  add_index "comments", ["rating"], :name => "index_comments_on_rating"

  create_table "competitions", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "organization"
    t.integer  "prize"
    t.float    "prize_value"
    t.boolean  "private"
    t.float    "fee"
    t.date     "open_on"
    t.date     "close_on"
    t.boolean  "paid"
    t.datetime "paid_at"
    t.boolean  "approved"
    t.datetime "approved_at"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "transferred"
    t.datetime "transferred_at"
    t.boolean  "winner_chosen"
    t.boolean  "artwork_submitted"
    t.boolean  "delta",             :default => true, :null => false
    t.boolean  "auto_extend"
    t.boolean  "extended"
    t.boolean  "expired"
    t.integer  "logo_format"
    t.integer  "logo_use"
    t.string   "sub_title"
    t.text     "target_audience"
    t.text     "requirement"
  end

  add_index "competitions", ["approved"], :name => "index_competitions_on_approved"
  add_index "competitions", ["delta"], :name => "index_competitions_on_delta"
  add_index "competitions", ["paid"], :name => "index_competitions_on_paid"
  add_index "competitions", ["person_id"], :name => "index_competitions_on_person_id"

  create_table "entries", :force => true do |t|
    t.integer  "kind"
    t.integer  "status"
    t.integer  "person_id"
    t.integer  "logo_id"
    t.integer  "enterable_id"
    t.string   "enterable_type", :default => "Competition"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rating"
  end

  add_index "entries", ["enterable_id"], :name => "index_entries_on_enterable_id"
  add_index "entries", ["enterable_type"], :name => "index_entries_on_enterable_type"
  add_index "entries", ["kind"], :name => "index_entries_on_kind"
  add_index "entries", ["logo_id"], :name => "index_entries_on_logo_id"
  add_index "entries", ["person_id"], :name => "index_entries_on_person_id"
  add_index "entries", ["status"], :name => "index_entries_on_status"

  create_table "favourites", :force => true do |t|
    t.integer  "rating"
    t.integer  "person_id"
    t.integer  "logo_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "logos", :force => true do |t|
    t.integer  "kind"
    t.string   "name"
    t.string   "strapline"
    t.text     "description"
    t.string   "brand_name"
    t.string   "brand_owner"
    t.string   "brand_owner_website"
    t.string   "access"
    t.string   "access_website"
    t.integer  "year_first_used"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "old_logo_id"
    t.boolean  "delta",               :default => true, :null => false
    t.boolean  "for_sale"
    t.float    "price"
    t.boolean  "sold"
    t.integer  "buyer_id"
    t.text     "sale_description"
  end

  add_index "logos", ["created_at"], :name => "index_logos_on_created_at"
  add_index "logos", ["delta"], :name => "index_logos_on_delta"
  add_index "logos", ["kind"], :name => "index_logos_on_kind"
  add_index "logos", ["person_id"], :name => "index_logos_on_person_id"
  add_index "logos", ["updated_at"], :name => "index_logos_on_updated_at"

  create_table "page_views", :force => true do |t|
    t.string   "ip_address"
    t.integer  "viewable_id"
    t.string   "viewable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "page_views", ["viewable_id"], :name => "index_page_views_on_viewable_id"
  add_index "page_views", ["viewable_type"], :name => "index_page_views_on_viewable_type"

  create_table "password_reset_coupons", :force => true do |t|
    t.string   "code"
    t.datetime "expire_at"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payments", :force => true do |t|
    t.string   "email"
    t.float    "amount"
    t.string   "status"
    t.text     "note"
    t.integer  "payable_id"
    t.string   "payable_type", :default => "Competition"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "people", :force => true do |t|
    t.integer  "kind"
    t.string   "nick_name"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "paypal_account"
    t.string   "password_hash"
    t.string   "password_salt"
    t.string   "last_login_at"
    t.string   "last_login_ip_address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.integer  "old_user_id"
    t.boolean  "delta",                 :default => true, :null => false
    t.boolean  "competition_winner"
    t.datetime "last_won_at"
    t.boolean  "active",                :default => true
  end

  add_index "people", ["competition_winner"], :name => "index_people_on_competition_winner"
  add_index "people", ["delta"], :name => "index_people_on_delta"
  add_index "people", ["email"], :name => "index_people_on_email"
  add_index "people", ["kind"], :name => "index_people_on_kind"
  add_index "people", ["last_won_at"], :name => "index_people_on_last_won_at"

  create_table "people_announcements", :force => true do |t|
    t.integer  "person_id"
    t.integer  "announcement_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "posts", :force => true do |t|
    t.string   "name"
    t.text     "excerpt"
    t.text     "body"
    t.string   "rewrite"
    t.datetime "publish_at"
    t.datetime "expires_at"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "delta",      :default => true, :null => false
  end

  create_table "profiles", :force => true do |t|
    t.string   "job_title"
    t.string   "company"
    t.string   "company_website"
    t.string   "location"
    t.string   "country"
    t.text     "biography"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "facebook"
    t.string   "twitter"
    t.integer  "company_size"
  end

  add_index "profiles", ["person_id"], :name => "index_profiles_on_person_id"

  create_table "projects", :force => true do |t|
    t.integer  "status"
    t.integer  "kind"
    t.integer  "permission"
    t.float    "prize_value"
    t.string   "name"
    t.text     "brief"
    t.date     "deadline"
    t.string   "url"
    t.string   "location"
    t.string   "company_size"
    t.string   "payment_term"
    t.string   "payment_currency"
    t.text     "other_requirement"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "delta",             :default => true, :null => false
    t.boolean  "approved"
  end

  create_table "simple_captcha_data", :force => true do |t|
    t.string   "key",        :limit => 40
    t.string   "value",      :limit => 6
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "statistics", :force => true do |t|
    t.integer "score"
    t.integer "rank"
    t.integer "number_of_comments"
    t.integer "number_of_views"
    t.integer "number_of_gold_medals"
    t.integer "number_of_silver_medals"
    t.integer "number_of_bronze_medals"
    t.integer "analyzable_id"
    t.string  "analyzable_type"
    t.integer "number_of_favourites"
    t.integer "number_of_projects"
  end

  add_index "statistics", ["analyzable_id"], :name => "index_statistics_on_analyzable_id"
  add_index "statistics", ["score"], :name => "index_statistics_on_score"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "tokens", :force => true do |t|
    t.string   "secret"
    t.string   "ip"
    t.string   "location"
    t.date     "expire"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transactions", :force => true do |t|
    t.integer  "kind"
    t.integer  "amount"
    t.text     "references"
    t.integer  "loggable_id"
    t.string   "loggable_type", :default => "Competition"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "action"
    t.string   "token"
    t.string   "ip_address"
    t.string   "payer_id"
    t.boolean  "success"
    t.string   "authorization"
    t.string   "message"
  end

end
