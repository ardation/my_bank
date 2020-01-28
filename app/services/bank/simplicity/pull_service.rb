class Bank::Simplicity::PullService
  attr_reader :bank

  def initialize(bank)
    @bank = bank
  end

  def client
    @client ||= Bank::Simplicity::ClientService.new(bank)
  end

  def self.pull(bank, _start_date, _end_date)
    instance = new(bank)
    instance.pull_accounts
  ensure
    instance.client.logout
  end

  def pull_accounts
    client.accounts.each do |remote_account|
      account = bank.accounts.find_or_initialize_by(remote_id: remote_account['InvestmentCode'])
      account.attributes = {
        name: "#{remote_account['InvestmentName']} (#{remote_account['Portfolio']})",
        nickname: remote_account['InvestmentType'],
        balance_posted_at: Time.zone.now,
        balance: remote_account['MarketValue'],
        remote_bank_id: remote_account['PortfolioCode']
      }
      account.save
      pull_transactions(account)
    end
  end

  def pull_transactions(account)
    client.transactions(account).each do |remote_transaction|
      transaction = account.transactions.find_or_initialize_by(remote_id: remote_transaction['Id'])
      transaction.attributes = transaction_attributes(account, remote_transaction)
      transaction.save
    end
  end

  protected

  def transaction_attributes(account, remote_transaction)
    {
      amount: remote_transaction['Units'].to_f * client.unit_price(account),
      name: remote_transaction['TransactionDescription'],
      memo: "#{remote_transaction['TransactionDisplayName']} #{remote_transaction['Value']}",
      posted_at: remote_transaction['EffectiveDate'].to_date,
      transaction_type: remote_transaction['TransactionMethodType']
    }.delete_if { |_k, v| v.nil? }
  end
end
