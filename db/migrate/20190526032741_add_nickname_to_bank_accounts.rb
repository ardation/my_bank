class AddNicknameToBankAccounts < ActiveRecord::Migration[6.0]
  def change
    add_column :bank_accounts, :nickname, :string
  end
end
