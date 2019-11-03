class AddPrecisionToAmountOnTransactions < ActiveRecord::Migration[6.0]
  def up
    change_column :bank_account_transactions, :amount, :decimal, precision: 15, scale: 2
  end

  def down
    change_column :bank_account_transactions, :amount, :decimal, precision: 8, scale: 2
  end
end
