#

class CreateBudgets < ActiveRecord::Migration[6.0]
  def change
    create_table :budgets, id: :uuid do |t|
      t.string :name
      t.string :remote_id

      t.timestamps
    end
    add_index :budgets, :remote_id, unique: true
  end
end
