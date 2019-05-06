class CreateBankAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :bank_accounts, id: :uuid do |t|
      t.string :name
      t.string :remote_id

      t.timestamps
    end
    add_index :bank_accounts, :remote_id, unique: true
  end
end
