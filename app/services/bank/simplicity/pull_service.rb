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
    instance.pull_transactions
  ensure
    instance.client.logout
  end

  def pull_transactions
    client.transactions.each do |remote_transaction|
      transaction = account.transactions.find_or_initialize_by(remote_id: remote_transaction['Transaction ID'])
      transaction.attributes = transaction_attributes(remote_transaction)
      transaction.save
    end
    account.update(
      balance: account.transactions.sum(:amount),
      balance_posted_at: Time.current
    )
  end

  protected

  def account
    bank.accounts.first || bank.accounts.create(name: 'KiwiSaver')
  end

  def transaction_attributes(remote_transaction)
    {
      amount: remote_transaction['Units'].to_f * client.unit_price,
      name: remote_transaction['Description'],
      memo: "#{remote_transaction['Transaction Display Name']} #{remote_transaction['Value']}",
      posted_at: remote_transaction['Effective Date'].to_date,
      transaction_type: remote_transaction['Transaction Method']
    }.delete_if { |_k, v| v.nil? }
  end
end
