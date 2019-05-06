class CreateBankAccountLinks < ActiveRecord::Migration[6.0]
  def change
    create_table :bank_account_links, id: :uuid do |t|
      t.belongs_to :bank_account,
                   null: false,
                   type: :uuid,
                   foreign_key: { on_delete: :cascade, to_table: :bank_accounts }
      t.belongs_to :budget_account,
                   null: false,
                   type: :uuid,
                   foreign_key: { on_delete: :cascade, to_table: :budget_accounts }

      t.timestamps
    end
  end
end
