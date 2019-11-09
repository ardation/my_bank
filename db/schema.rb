# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_11_09_195918) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "bank_account_transactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "amount", precision: 15, scale: 2
    t.string "check_number"
    t.string "memo"
    t.string "name"
    t.string "payee"
    t.date "posted_at"
    t.string "ref_number"
    t.string "transaction_type"
    t.string "sic"
    t.string "remote_id"
    t.uuid "account_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "occurred_at"
    t.index ["account_id", "remote_id"], name: "index_bank_account_transactions_on_account_id_and_remote_id", unique: true
    t.index ["account_id"], name: "index_bank_account_transactions_on_account_id"
    t.index ["remote_id"], name: "index_bank_account_transactions_on_remote_id"
  end

  create_table "bank_accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.uuid "bank_id", null: false
    t.string "remote_id"
    t.string "balance"
    t.datetime "balance_posted_at"
    t.string "remote_bank_id"
    t.string "remote_account_id"
    t.string "currency"
    t.string "account_type"
    t.string "available_balance"
    t.datetime "available_balance_posted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "nickname"
    t.index ["bank_id", "remote_id"], name: "index_bank_accounts_on_bank_id_and_remote_id", unique: true
    t.index ["bank_id"], name: "index_bank_accounts_on_bank_id"
    t.index ["remote_id"], name: "index_bank_accounts_on_remote_id"
  end

  create_table "banks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "encrypted_username"
    t.string "encrypted_username_iv"
    t.string "encrypted_password"
    t.string "encrypted_password_iv"
    t.string "type"
    t.uuid "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "session"
    t.datetime "locked_at"
    t.datetime "last_sync_attempted_at"
    t.datetime "last_sync_at"
    t.index ["encrypted_password_iv"], name: "index_banks_on_encrypted_password_iv", unique: true
    t.index ["encrypted_username_iv"], name: "index_banks_on_encrypted_username_iv", unique: true
    t.index ["user_id"], name: "index_banks_on_user_id"
  end

  create_table "integration_ynab_budget_account_links", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "bank_account_id", null: false
    t.uuid "budget_account_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["bank_account_id", "budget_account_id"], name: "idx_ynab_budget_account_link_uniq_ids", unique: true
    t.index ["bank_account_id"], name: "idx_ynab_budget_account_link_bank"
    t.index ["budget_account_id"], name: "idx_ynab_budget_account_link_budget"
  end

  create_table "integration_ynab_budget_accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "remote_id"
    t.uuid "budget_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["budget_id", "remote_id"], name: "idx_ynab_budget_account_ids", unique: true
    t.index ["budget_id"], name: "index_integration_ynab_budget_accounts_on_budget_id"
  end

  create_table "integration_ynab_budgets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "integration_id", null: false
    t.string "name"
    t.string "remote_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["integration_id", "remote_id"], name: "idx_ynab_budget_ids", unique: true
    t.index ["integration_id"], name: "index_integration_ynab_budgets_on_integration_id"
  end

  create_table "integrations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "type"
    t.uuid "user_id", null: false
    t.string "provider"
    t.string "uid"
    t.text "info"
    t.text "credentials"
    t.text "extra"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "locked_at"
    t.datetime "last_sync_attempted_at"
    t.datetime "last_sync_at"
    t.index ["user_id", "type"], name: "index_integrations_on_user_id_and_type", unique: true
    t.index ["user_id"], name: "index_integrations_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "admin"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "bank_account_transactions", "bank_accounts", column: "account_id", on_delete: :cascade
  add_foreign_key "bank_accounts", "banks", on_delete: :cascade
  add_foreign_key "banks", "users", on_delete: :cascade
  add_foreign_key "integration_ynab_budget_account_links", "bank_accounts", name: "idx_ynab_budget_account_link_bank_fk", on_delete: :cascade
  add_foreign_key "integration_ynab_budget_account_links", "integration_ynab_budget_accounts", column: "budget_account_id", name: "idx_ynab_budget_account_link_budget_fk", on_delete: :cascade
  add_foreign_key "integration_ynab_budget_accounts", "integration_ynab_budgets", column: "budget_id", on_delete: :cascade
  add_foreign_key "integration_ynab_budgets", "integrations", on_delete: :cascade
  add_foreign_key "integrations", "users", on_delete: :cascade
end
