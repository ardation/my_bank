class Bank::Asb::PullService
  attr_reader :bank

  def initialize(bank)
    @bank = bank
  end

  def client
    @client ||= Bank::Asb::ClientService.new(bank)
  end

  def self.pull(bank, _start_date, _end_date)
    instance = new(bank)
    instance.pull_accounts
  ensure
    instance.client.logout
  end

  def pull_accounts
    client.accounts.each do |name, remote_account|
      account = bank.accounts.find_or_initialize_by(remote_id: "#{remote_account.bank_id}-#{remote_account.id}")
      account.attributes = account_attributes(remote_account).merge(name: name)
      account.save
      pull_transactions(account, remote_account.transactions)
    end
  end

  protected

  def pull_transactions(account, remote_transactions)
    remote_transactions.each do |remote_transaction|
      transaction = account.transactions.find_or_initialize_by(remote_id: remote_transaction.fit_id)
      transaction.attributes = transaction_attributes(remote_transaction)
      transaction.save
    end
  end

  def account_attributes(remote_account)
    {
      balance: remote_account.balance.amount,
      balance_posted_at: remote_account.balance.posted_at,
      remote_bank_id: remote_account.bank_id,
      remote_account_id: remote_account.id,
      currency: remote_account.currency,
      account_type: remote_account.type,
      available_balance: remote_account.available_balance.amount,
      available_balance_posted_at: remote_account.available_balance.posted_at
    }.delete_if { |_k, v| v.nil? }
  end

  def transaction_attributes(remote_transaction)
    {
      amount: remote_transaction.amount,
      check_number: remote_transaction.check_number,
      memo: remote_transaction.memo,
      name: remote_transaction.name,
      payee: remote_transaction.payee,
      posted_at: remote_transaction.posted_at,
      ref_number: remote_transaction.ref_number,
      transaction_type: remote_transaction.type,
      sic: remote_transaction.sic
    }.delete_if { |_k, v| v.nil? }
  end
end
