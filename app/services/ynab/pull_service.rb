class Ynab::PullService
  def client
    @client ||= Ynab::ClientService.new
  end

  def self.pull
    instance = new
    instance.pull_budgets
    instance.pull_accounts
  end

  def pull_budgets
    client.budgets.each do |remote_budget|
      budget = Budget.find_or_initialize_by(remote_id: remote_budget['id'])
      budget.attributes = {
        name: remote_budget['name']
      }
      budget.save
    end
  end

  def pull_accounts
    Budget.find_each do |budget|
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
