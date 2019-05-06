class CreateBudgetAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :budget_accounts, id: :uuid do |t|
      t.string :name
      t.string :remote_id
      t.belongs_to :budget

      t.timestamps
    end
    add_index :budget_accounts, :remote_id, unique: true
  end
end
