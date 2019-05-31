class AddUniqIndexToIntegrations < ActiveRecord::Migration[6.0]
  def change
    add_index :integrations, %i[user_id type], unique: true
  end
end
