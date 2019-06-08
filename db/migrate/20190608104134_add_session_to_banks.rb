class AddSessionToBanks < ActiveRecord::Migration[6.0]
  def change
    add_column :banks, :session, :text
  end
end
