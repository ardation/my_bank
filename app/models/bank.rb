class Bank < ApplicationRecord
  belongs_to :user
  has_many :accounts, dependent: :destroy

  attr_encrypted :username, key: [ENV.fetch('BANK_USERNAME_KEY')].pack('H*')
  attr_encrypted :password, key: [ENV.fetch('BANK_PASSWORD_KEY')].pack('H*')

  validates :type, presence: true

  def pull
    "#{self.class.name}::PullService".classify.constantize.pull(self)
  rescue NameError
    raise NoMethodError 'Bank base class does not implement pull'
  end

  def login
    "#{self.class.name}::ClientService".classify.constantize.login(self)
  rescue NameError
    raise NoMethodError 'Bank base class does not implement pull'
  end
end
