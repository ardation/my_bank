class Anz::PullService
  def client
    @client ||= Anz::ClientService.new
  end

  def self.pull
    instance = new
    instance.pull_accounts
    instance.pull_transactions
  ensure
    instance.client.logout
  end

  def pull_accounts
    client.accounts.each do |remote_account|
      account = Bank::Account.find_or_initialize_by(remote_id: remote_account['accountNumber'])
      account.attributes = {
        name: [remote_account['productName'], remote_account['nickname']].compact.join(', ')
      }
      account.save
    end
  end

  def pull_transactions
    client.accounts.each do |remote_account|
      account = Bank::Account.find_by!(remote_id: remote_account['accountNumber'])
      next if account.links.blank?

      client.transactions(remote_account['id']).each do |remote_transaction|
        transaction = get_transaction(account, remote_transaction)
        transaction.save
      end
    end
  end

  protected

  def get_transaction(account, remote_transaction)
    account.transactions
           .find_or_initialize_by(
             amount: remote_transaction['amount']['amount'],
             date: Date.strptime(remote_transaction['date'], '%Y-%m-%d'),
             payee_name: remote_transaction['details'][0].strip,
             memo: remote_transaction['details'][1].strip
           )
  end
end
