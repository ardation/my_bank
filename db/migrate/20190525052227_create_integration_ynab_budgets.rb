class CreateIntegrationYnabBudgets < ActiveRecord::Migration[6.0]
  def change
    create_table :integration_ynab_budgets, id: :uuid do |t|
      t.belongs_to :integration, null: false, type: :uuid, foreign_key: { on_delete: :cascade }
      t.string :name
      t.string :remote_id

      t.timestamps
    end
    add_index :integration_ynab_budgets,
              %i[integration_id remote_id],
              name: 'idx_ynab_budget_ids',
              unique: true
  end
end
