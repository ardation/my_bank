class AddLockingColumnsToModels < ActiveRecord::Migration[6.0]
  def change
    add_column :banks, :locked_at, :timestamp
    add_column :banks, :last_sync_attempted_at, :timestamp
    add_column :banks, :last_sync_at, :timestamp
    add_column :integrations, :locked_at, :timestamp
    add_column :integrations, :last_sync_attempted_at, :timestamp
    add_column :integrations, :last_sync_at, :timestamp
  end
end
