class Bank < ApplicationRecord
  class AuthenticationError < StandardError; end

  TYPES = {
    'ANZ' => 'Bank::Anz',
    'ASB' => 'Bank::Asb'
  }.freeze

  belongs_to :user
  has_many :accounts, dependent: :destroy

  attr_encrypted :username, key: ->(_bank) { [Rails.application.credentials.bank[:username_key]].pack('H*') }
  attr_encrypted :password, key: ->(_bank) { [Rails.application.credentials.bank[:password_key]].pack('H*') }

  validates :type, inclusion: { in: Bank::TYPES.values }, presence: true
  validates :username, :password, presence: true
  validate :validate_credentials

  after_commit :perform_sync, on: %i[create update]

  serialize :session, JSON

  def sync(start_date = (Time.zone.today - 1.month).beginning_of_month, end_date = Time.zone.today)
    return unless Bank::TYPES.values.include?(type)

    "#{type}::PullService".classify.constantize.pull(self, start_date, end_date)
  end

  protected

  def perform_sync
    Bank::SyncWorker.perform_async(id)
  end

  def validate_credentials
    return false unless Bank::TYPES.values.include?(type) && username.present? && password.present?

    client = "#{type}::ClientService".classify.constantize.new(self)
    client.logout
  rescue Bank::AuthenticationError
    errors.add(:username, 'or password invalid')
    errors.add(:password, 'or username invalid')
  end
end
