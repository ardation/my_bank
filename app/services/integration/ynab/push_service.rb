class Integration::Ynab::PushService
  attr_reader :integration

  def initialize(integration)
    @integration = integration
  end

  def client
    @client ||= Integration::Ynab::ClientService.new(integration)
  end

  def self.push
    instance = new
    instance.push_transactions
  end

  def push_transactions
    integration.budgets.find_each do |budget|
      budget.accounts.find_each do |budget_account|
        transactions = budget_account.transactions
        next if transactions.blank?

        client.create_transactions(budget.remote_id, transactions_attributes(budget_account.remote_id, transactions))
      end
    end
  end

  protected

  def transactions_attributes(account_id, transactions)
    transactions.map do |transaction|
      {
        account_id: account_id,
        date: transaction.date.strftime,
        amount: (transaction.amount * 1000).to_i,
        payee_name: transaction.payee_name,
        memo: transaction.memo
      }
    end
  end
end
