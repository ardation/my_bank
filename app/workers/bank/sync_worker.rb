class Bank::SyncWorker < ApplicationWorker
  sidekiq_options lock: :until_executed

  def perform(bank_id)
    Bank.find_by(id: bank_id)&.sync
  end
end
