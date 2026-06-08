# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_08_120000) do
  create_table "active_storage_attachments", id: :string, force: :cascade do |t|
    t.string "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :string, force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: :string, force: :cascade do |t|
    t.string "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "albums", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "slug", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_albums_on_slug", unique: true
  end

  create_table "comments", id: :string, force: :cascade do |t|
    t.string "author_id", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.string "moment_id", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_comments_on_author_id"
    t.index ["moment_id"], name: "index_comments_on_moment_id"
  end

  create_table "likes", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "moment_id", null: false
    t.string "ownership_id", null: false
    t.datetime "updated_at", null: false
    t.index ["moment_id", "ownership_id"], name: "index_likes_on_moment_id_and_ownership_id", unique: true
    t.index ["ownership_id"], name: "index_likes_on_ownership_id"
  end

  create_table "moments", id: :string, force: :cascade do |t|
    t.string "album_id", null: false
    t.datetime "captured_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.integer "comments_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.integer "likes_count", default: 0, null: false
    t.string "type", null: false
    t.datetime "updated_at", null: false
    t.string "uploader_id", null: false
    t.index ["album_id", "captured_at"], name: "index_moments_on_album_id_and_captured_at"
    t.index ["type"], name: "index_moments_on_type"
    t.index ["uploader_id"], name: "index_moments_on_uploader_id"
  end

  create_table "ownerships", id: :string, force: :cascade do |t|
    t.string "album_id", null: false
    t.datetime "created_at", null: false
    t.integer "moments_count", default: 0, null: false
    t.integer "position", null: false
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.string "user_id", null: false
    t.index ["album_id", "position"], name: "index_ownerships_on_album_id_and_position", unique: true
    t.index ["album_id", "user_id"], name: "index_ownerships_on_album_id_and_user_id", unique: true
    t.index ["user_id"], name: "index_ownerships_on_user_id"
  end

  create_table "users", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.json "roles", default: [], null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "comments", "moments"
  add_foreign_key "comments", "ownerships", column: "author_id"
  add_foreign_key "likes", "moments"
  add_foreign_key "likes", "ownerships"
  add_foreign_key "moments", "albums"
  add_foreign_key "moments", "ownerships", column: "uploader_id"
  add_foreign_key "ownerships", "albums"
  add_foreign_key "ownerships", "users"
end
