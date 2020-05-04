class Bank::SyncWorker < ApplicationWorker
  sidekiq_options lock: :until_executed, retry: false

  def perform(bank_id)
    Bank.find_by(id: bank_id, locked_at: nil)&.sync
  end
end
