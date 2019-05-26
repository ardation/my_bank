class Bank::Anz::PullService
  attr_reader :bank

  def initialize(bank)
    @bank = bank
  end

  def client
    @client ||= Bank::Anz::ClientService.new(bank)
  end

  def self.pull(bank)
    instance = new(bank)
    instance.pull_accounts
  ensure
    instance.client.logout
  end

  def pull_accounts
    client.accounts.each do |remote_account|
      account = bank.accounts.find_or_initialize_by(remote_id: remote_account[:anz_account]['accountNumber'])
      account.attributes = account_attributes(remote_account[:anz_account], remote_account[:ofx_account])
      account.save
      pull_transactions(account, remote_account[:ofx_account].transactions) if remote_account[:ofx_account]
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

  def account_attributes(anz_account, ofx_account)
    {
      name: anz_account['productName'],
      nickname: anz_account['nickname'],
      balance: ofx_account&.balance&.amount || anz_account.dig('balance', 'amount'),
      balance_posted_at: ofx_account&.balance&.posted_at || Time.zone.now,
      remote_bank_id: ofx_account&.bank_id,
      remote_account_id: ofx_account&.id,
      currency: ofx_account&.currency || anz_account.dig('balance', 'currencyCode'),
      account_type: ofx_account&.type || anz_account['accountType'],
      available_balance: ofx_account&.available_balance&.amount || anz_account.dig('availableFunds', 'amount'),
      available_balance_posted_at: ofx_account&.available_balance&.posted_at || Time.zone.now
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
