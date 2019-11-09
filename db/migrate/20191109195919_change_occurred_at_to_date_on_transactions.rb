class ChangeOccurredAtToDateOnTransactions < ActiveRecord::Migration[6.0]
  def up
    change_column :bank_account_transactions, :occurred_at, :date
  end

  def down
    change_column :bank_account_transactions, :occurred_at, :datetime
  end
end
