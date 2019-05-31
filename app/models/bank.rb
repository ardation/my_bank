class Bank < ApplicationRecord
  class AuthenticationError < StandardError; end

  TYPES = {
    'ANZ' => 'Bank::Anz',
    'ASB' => 'Bank::Asb'
  }.freeze

  belongs_to :user
  has_many :accounts, dependent: :destroy

  attr_encrypted :username, key: [ENV.fetch('BANK_USERNAME_KEY')].pack('H*')
  attr_encrypted :password, key: [ENV.fetch('BANK_PASSWORD_KEY')].pack('H*')

  validates :type, inclusion: { in: Bank::TYPES.values }, presence: true
  validates :username, :password, presence: true
  validate :validate_credentials

  def sync
    pull
  end

  def pull
    return unless Bank::TYPES.values.include?(type)

    "#{type}::PullService".classify.constantize.pull(self)
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
