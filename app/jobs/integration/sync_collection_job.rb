class Integration::SyncCollectionJob < ApplicationJob
  def perform
    Integration.find_each do |integration|
      Integration::SyncJob.perform(integration)
    end
  end
end
