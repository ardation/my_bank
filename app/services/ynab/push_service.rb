class Ynab::PushService
  def client
    @client ||= Ynab::ClientService.new
  end

  def self.push
    instance = new
    instance.push_transactions
  end

  def push_transactions
    Budget.find_each do |budget|
      budget.accounts.find_each do |budget_account|
        transactions = budget_account.transactions.where(sync: false)
        next if transactions.blank?

        client.create_transactions(budget.remote_id, transactions_attributes(budget_account.remote_id, transactions))
        transactions.update_all(sync: true) # rubocop:disable Rails/SkipsModelValidations
      end
    end
  end

  protected

  def transactions_attributes(account_id, transactions)
    transactions.map do |transaction|
      {
        account_id: account_id,
        date: transaction.date.strftime,
        amount: (transaction.amount * 100).to_i,
        payee_name: transaction.payee_name,
        memo: transaction.memo
      }
    end
  end
end
