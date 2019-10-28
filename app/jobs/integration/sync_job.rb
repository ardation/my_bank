class Integration::SyncJob < ApplicationJob
  def perform(integration)
    integration.sync
  end
end
