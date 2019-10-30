class Integration::SyncWorker < ApplicationWorker
  sidekiq_options lock: :until_executed

  def perform(integration_id)
    Integration.find_by(id: integration_id)&.sync
  end
end
