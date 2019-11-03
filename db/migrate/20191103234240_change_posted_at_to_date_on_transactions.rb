class ChangePostedAtToDateOnTransactions < ActiveRecord::Migration[6.0]
  def up
    change_column :bank_account_transactions, :posted_at, :date
  end

  def down
    change_column :bank_account_transactions, :posted_at, :datetime
  end
end
