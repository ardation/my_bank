class CreateBankAccountTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :bank_account_transactions, id: :uuid do |t|
      t.date :date
      t.string :payee_name
      t.string :memo
      t.decimal :amount
      t.belongs_to :account, null: false, foreign_key: { on_delete: :cascade, to_table: :bank_accounts }, type: :uuid

      t.timestamps
    end
  end
end
