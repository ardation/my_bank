class User < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :timeoutable, :trackable, :registerable

  has_many :banks, dependent: :destroy
  has_many :bank_accounts, through: :banks, source: :accounts, class_name: 'Bank::Account'
  has_many :integrations, dependent: :destroy

  def add_integration(provider, auth)
    integration = integrations.find_or_initialize_by(
      type: "Integration::#{provider.classify}",
      provider: provider
    )
    integration.attributes = auth
    integration.save

    integration
  end
end
