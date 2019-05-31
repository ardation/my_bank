class CreateIntegrationYnabBudgetAccountLinks < ActiveRecord::Migration[6.0]
  def change
    create_table :integration_ynab_budget_account_links, id: :uuid do |t|
      t.belongs_to :bank_account,
                   null: false,
                   index: {
                     name: 'idx_ynab_budget_account_link_bank'
                   },
                   foreign_key: {
                     on_delete: :cascade,
                     to_table: :bank_accounts,
                     name: 'idx_ynab_budget_account_link_bank_fk'
                   },
                   type: :uuid
      t.belongs_to :budget_account,
                   null: false,
                   index: {
                     name: 'idx_ynab_budget_account_link_budget'
                   },
                   foreign_key: {
                     on_delete: :cascade,
                     to_table: :integration_ynab_budget_accounts,
                     name: 'idx_ynab_budget_account_link_budget_fk'
                   },
                   type: :uuid

      t.timestamps
    end

    add_index :integration_ynab_budget_account_links,
              %i[bank_account_id budget_account_id],
              unique: true,
              name: 'idx_ynab_budget_account_link_uniq_ids'
  end
end
