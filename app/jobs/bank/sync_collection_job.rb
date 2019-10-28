class Bank::SyncCollectionJob < ApplicationJob
  def perform
    Bank.find_each do |bank|
      Bank::SyncJob.perform_later(bank)
    end
  end
end
