class Integration::Ynab::PushService
  attr_reader :integration

  def initialize(integration)
    @integration = integration
  end

  def client
    @client ||= Integration::Ynab::ClientService.new(integration)
  end

  def self.push(integration)
    instance = new(integration)
    instance.push
  end

  def push
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
        date: transaction.posted_at.strftime('%Y-%m-%d'),
        amount: (transaction.amount * 1000).to_i,
        payee_name: transaction.name,
        memo: transaction.memo,
        import_id: transaction.id
      }
    end
  end
end
