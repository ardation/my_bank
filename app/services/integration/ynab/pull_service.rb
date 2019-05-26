class Integration::Ynab::PullService
  attr_reader :integration

  def initialize(integration)
    @integration = integration
  end

  def client
    @client ||= Integration::Ynab::ClientService.new(integration)
  end

  def self.pull(integration)
    instance = new(integration)
    instance.pull_budgets
    instance.pull_accounts
  end

  def pull_budgets
    client.budgets.each do |remote_budget|
      budget = integration.budgets.find_or_initialize_by(remote_id: remote_budget['id'])
      budget.attributes = {
        name: remote_budget['name']
      }
      budget.save
    end
  end

  def pull_accounts
    integration.budgets.find_each do |budget|
      client.accounts(budget.remote_id).each do |remote_account|
        account = budget.accounts.find_or_initialize_by(remote_id: remote_account['id'])
        account.attributes = {
          name: remote_account['name']
        }
        account.save
      end
    end
  end
end
