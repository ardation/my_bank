class Bank::SyncCollectionWorker < ApplicationWorker
  def perform
    Bank.where(locked_at: nil).find_each do |bank|
      Bank::SyncWorker.perform_async(bank.id)
    end
  end
end
