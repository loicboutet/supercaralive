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

ActiveRecord::Schema[8.0].define(version: 2025_11_17_144529) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "professional_documents", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name"
    t.string "file"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "comments"
    t.index ["user_id"], name: "index_professional_documents_on_user_id"
  end

  create_table "professional_service_services", force: :cascade do |t|
    t.integer "professional_service_id", null: false
    t.integer "service_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["professional_service_id", "service_id"], name: "index_prof_service_services_unique", unique: true
    t.index ["professional_service_id"], name: "index_professional_service_services_on_professional_service_id"
    t.index ["service_id"], name: "index_professional_service_services_on_service_id"
  end

  create_table "professional_services", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name", null: false
    t.decimal "price", precision: 8, scale: 2
    t.integer "duration_minutes"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "pricing_type"
    t.decimal "flat_rate_price", precision: 8, scale: 2
    t.decimal "hourly_rate_price", precision: 8, scale: 2
    t.string "travel_pricing_type"
    t.decimal "travel_flat_rate", precision: 8, scale: 2
    t.decimal "travel_per_km_rate", precision: 8, scale: 2
    t.index ["active"], name: "index_professional_services_on_active"
    t.index ["user_id"], name: "index_professional_services_on_user_id"
  end

  create_table "services", force: :cascade do |t|
    t.string "name", null: false
    t.text "description", null: false
    t.string "category", null: false
    t.string "icon"
    t.integer "estimated_duration"
    t.decimal "suggested_price", precision: 8, scale: 2
    t.boolean "active", default: true, null: false
    t.boolean "popular", default: false, null: false
    t.boolean "requires_quote", default: false, null: false
    t.text "prerequisites"
    t.text "internal_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_services_on_active"
    t.index ["category"], name: "index_services_on_category"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "role", default: "Client", null: false
    t.string "status", default: "active"
    t.string "phone_number"
    t.string "location"
    t.boolean "cgu_accepted", default: false, null: false
    t.string "company_name"
    t.text "admin_approval_note"
    t.string "siret"
    t.string "intervention_zone"
    t.text "professional_presentation"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "professional_documents", "users"
  add_foreign_key "professional_service_services", "professional_services"
  add_foreign_key "professional_service_services", "services"
  add_foreign_key "professional_services", "users"
end
