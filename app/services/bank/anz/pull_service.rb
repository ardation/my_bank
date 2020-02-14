class Bank::Anz::PullService
  attr_reader :bank

  def initialize(bank)
    @bank = bank
  end

  def client
    @client ||= Bank::Anz::ClientService.new(bank)
  end

  def self.pull(bank, start_date, end_date)
    instance = new(bank)
    instance.pull_accounts(start_date, end_date)
  ensure
    instance.client.logout
  end

  def pull_accounts(start_date, end_date)
    client.accounts(start_date, end_date).each(&method(:pull_remote_account))
  end

  protected

  def pull_remote_account(remote_account)
    account = bank.accounts.find_or_initialize_by(remote_id: remote_account[:anz_account]['accountNumber'])
    account.attributes = account_attributes(remote_account[:anz_account], remote_account[:ofx_account])
    account.save
    ofx_pull_transactions(account, remote_account[:ofx_account].transactions) if remote_account[:ofx_account]
    json_pull_transactions(account, remote_account[:json_account]) if remote_account[:json_account]
  end

  def ofx_pull_transactions(account, remote_transactions)
    remote_transactions.each do |remote_transaction|
      transaction = account.transactions.find_or_initialize_by(remote_id: remote_transaction.fit_id)
      transaction.attributes = ofx_transaction_attributes(remote_transaction)
      transaction.save
    end
  end

  def json_pull_transactions(account, remote_transactions)
    remote_transactions.each do |remote_transaction|
      attributes = json_transaction_attributes(remote_transaction)

      transaction = find_or_initialize_transaction_by(account, attributes)
      transaction.attributes = attributes
      transaction.save
    end
  end

  def find_or_initialize_transaction_by(account, attributes)
    transaction = account.transactions.find_by(attributes)
    return account.transactions.build if attributes[:posted_at].nil?

    fuzzy_transactions = account.transactions.where(
      'amount > ? AND amount < ?', attributes[:amount] - 1, attributes[:amount] + 1
    ).where(
      occurred_at: (attributes[:occurred_at] - 1.day)..(attributes[:occurred_at] + 1.day),
      posted_at: nil
    ).where(attributes.slice(:ref_number, :transaction_type))
    transaction ||= FuzzyMatch.new(fuzzy_transactions, read: :name).find(attributes[:name])
    transaction || account.transactions.build
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

  def ofx_transaction_attributes(remote_transaction)
    {
      amount: remote_transaction.amount,
      check_number: remote_transaction.check_number,
      memo: remote_transaction.memo,
      name: remote_transaction.name,
      payee: remote_transaction.payee,
      posted_at: remote_transaction.posted_at,
      occurred_at: remote_transaction.occurred_at,
      ref_number: remote_transaction.ref_number,
      transaction_type: remote_transaction.type,
      sic: remote_transaction.sic
    }.delete_if { |_k, v| v.nil? }
  end

  def json_transaction_attributes(remote_transaction)
    {
      amount: json_transaction_amount(remote_transaction),
      memo: remote_transaction['details'].try(:[], 1),
      name: remote_transaction['details'][0].squish,
      posted_at: remote_transaction['postedDate'],
      occurred_at: Date.strptime(remote_transaction['date']),
      ref_number: remote_transaction['cardNo'],
      transaction_type: json_transaction_type(remote_transaction)
    }.delete_if { |_k, v| v.nil? }
  end

  def json_transaction_amount(remote_transaction)
    if remote_transaction['debitAmount']
      -remote_transaction['debitAmount']['amount']
    else
      remote_transaction['creditAmount']['amount']
    end
  end

  def json_transaction_type(remote_transaction)
    remote_transaction['debitAmount'] ? 'debit' : 'credit'
  end
end
