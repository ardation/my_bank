class Bank::SyncJob < ApplicationJob
  def perform(bank)
    bank.sync
  end
end
