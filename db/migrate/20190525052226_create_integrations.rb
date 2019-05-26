class CreateIntegrations < ActiveRecord::Migration[6.0]
  def change
    create_table :integrations, id: :uuid do |t|
      t.string :type
      t.belongs_to :user, null: false, type: :uuid, foreign_key: { on_delete: :cascade }
      t.string :provider
      t.string :uid
      t.text :info
      t.text :credentials
      t.text :extra

      t.timestamps
    end
  end
end
