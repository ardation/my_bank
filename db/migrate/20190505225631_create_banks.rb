class CreateBanks < ActiveRecord::Migration[6.0]
  def change
    create_table :banks, id: :uuid do |t|
      t.string :encrypted_username
      t.string :encrypted_username_iv
      t.string :encrypted_password
      t.string :encrypted_password_iv
      t.string :type
      t.belongs_to :user, null: false, type: :uuid, foreign_key: { on_delete: :cascade }
      t.timestamps
    end

    add_index :banks, :encrypted_username_iv, unique: true
    add_index :banks, :encrypted_password_iv, unique: true
  end
end
