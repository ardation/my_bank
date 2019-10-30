class Integration::SyncCollectionWorker < ApplicationWorker
  def perform
    Integration.find_each do |integration|
      Integration::SyncWorker.perform_later(integration.id)
    end
  end
end
