class Integration < ApplicationRecord
  belongs_to :user
  serialize :info, Hash
  serialize :credentials, Hash
  serialize :extra, Hash

  after_commit :perform_sync, on: %i[create update]

  TYPES = {
    'YNAB' => 'Integration::Ynab'
  }.freeze

  validates :type, inclusion: { in: Integration::TYPES.values }, presence: true

  # rubocop:disable Rails/SkipsModelValidations
  def sync
    return if locked_at.present?

    begin
      time_update_began = Time.current
      update_columns(locked_at: time_update_began, last_sync_attempted_at: time_update_began)
      pull
      push
      update_columns(last_sync_at: time_update_began)
    ensure
      update_columns(locked_at: nil)
    end
  end
  # rubocop:enable Rails/SkipsModelValidations

  def pull
    return unless Integration::TYPES.values.include?(type)

    "#{type}::PullService".classify.constantize.pull(self)
  end

  def push
    return unless Integration::TYPES.values.include?(type)

    "#{type}::PushService".classify.constantize.push(self)
  end

  protected

  def perform_sync
    Integration::SyncWorker.perform_async(id)
  end
end
