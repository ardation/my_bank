class Integration::SyncCollectionJob < ApplicationJob
  def perform
    Integration.find_each do |integration|
      Integration::SyncJob.perform_later(integration)
    end
  end
end
