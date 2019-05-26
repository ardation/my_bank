class CreateIntegrationYnabBudgetAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :integration_ynab_budget_accounts, id: :uuid do |t|
      t.string :name
      t.string :remote_id
      t.belongs_to :budget,
                   null: false,
                   foreign_key: { on_delete: :cascade, to_table: :integration_ynab_budgets },
                   type: :uuid

      t.timestamps
    end
    add_index :integration_ynab_budget_accounts,
              %i[budget_id remote_id],
              unique: true,
              name: 'idx_ynab_budget_account_ids'
  end
end
