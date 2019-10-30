class Bank::SyncCollectionWorker < ApplicationWorker
  def perform
    Bank.find_each do |bank|
      Bank::SyncWorker.perform_async(bank.id)
    end
  end
end
