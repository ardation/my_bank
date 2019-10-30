class Integration::SyncCollectionWorker < ApplicationWorker
  def perform
    Integration.where(locked_at: nil).find_each do |integration|
      Integration::SyncWorker.perform_later(integration.id)
    end
  end
end
