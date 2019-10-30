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

  def sync
    pull
    push
  end

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
