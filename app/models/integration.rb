class Integration < ApplicationRecord
  belongs_to :user
  serialize :info, Hash
  serialize :credentials, Hash
  serialize :extra, Hash

  TYPES = {
    'YNAB' => 'Integration::Ynab'
  }.freeze

  validates :type, inclusion: { in: Integration::TYPES.values }, presence: true

  def pull
    return unless Integration::TYPES.values.include?(type)

    "#{type}::PullService".classify.constantize.pull(self)
  end

  def push
    return unless Integration::TYPES.values.include?(type)

    "#{type}::PushService".classify.constantize.push(self)
  end
end
