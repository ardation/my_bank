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

  # rubocop:disable Rails/SkipsModelValidations
  def sync(start_date = nil, end_date = Time.zone.today)
    return unless Bank::TYPES.values.include?(type) && locked_at.nil?

    start_date ||= ((last_sync_at || 2.years.ago) - 1.month).beginning_of_month

    begin
      time_update_began = Time.current
      update_columns(locked_at: time_update_began, last_sync_attempted_at: time_update_began)
      "#{type}::PullService".classify.constantize.pull(self, start_date, end_date)
      update_columns(last_sync_at: time_update_began)
    ensure
      update_columns(locked_at: nil)
    end
  end
  # rubocop:enable Rails/SkipsModelValidations

  def perform_sync
    Bank::SyncWorker.perform_async(id)
  end

  protected

  def validate_credentials
    return false unless Bank::TYPES.values.include?(type) && username.present? && password.present?

    client = "#{type}::ClientService".classify.constantize.new(self)
    client.logout
  rescue Bank::AuthenticationError
    errors.add(:username, 'or password invalid')
    errors.add(:password, 'or username invalid')
  end
end
