class AddOccurredAtToBankAccountTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :bank_account_transactions, :occurred_at, :timestamp
  end
end
