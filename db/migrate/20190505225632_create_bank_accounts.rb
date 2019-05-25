class CreateBankAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :bank_accounts, id: :uuid do |t|
      t.string :name
      t.belongs_to :bank, null: false, type: :uuid, foreign_key: { on_delete: :cascade }
      t.string :remote_id, index: true
      t.string :balance
      t.timestamp :balance_posted_at
      t.string :remote_bank_id
      t.string :remote_account_id
      t.string :currency
      t.string :account_type
      t.string :available_balance
      t.timestamp :available_balance_posted_at

      t.timestamps
    end
    add_index :bank_accounts, %i[bank_id remote_id], unique: true
  end
end
