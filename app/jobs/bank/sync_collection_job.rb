class Bank::SyncCollectionJob < ApplicationJob
  def perform
    Bank.find_each do |bank|
      Bank::SyncJob.perform(bank)
    end
  end
end
