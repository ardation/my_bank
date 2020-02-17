class ClearLockedWorker < ApplicationWorker
  sidekiq_options lock: :until_executed

  def perform
    # rubocop:disable Rails/SkipsModelValidations
    Bank.where('locked_at < ?', 12.hours.ago).update_all(locked_at: nil)
    Integration.where('locked_at < ?', 12.hours.ago).update_all(locked_at: nil)
    # rubocop:enable Rails/SkipsModelValidations
  end
end
