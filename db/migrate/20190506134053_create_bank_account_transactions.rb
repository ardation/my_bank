class CreateBankAccountTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :bank_account_transactions, id: :uuid do |t|
      t.decimal :amount, precision: 8, scale: 2
      t.string :check_number
      t.string :memo
      t.string :name
      t.string :payee
      t.timestamp :posted_at
      t.string :ref_number
      t.string :transaction_type
      t.string :sic
      t.string :remote_id, index: true
      t.belongs_to :account, null: false, foreign_key: { on_delete: :cascade, to_table: :bank_accounts }, type: :uuid

      t.timestamps
    end
    add_index :bank_account_transactions, %i[account_id remote_id], unique: true
  end
end
