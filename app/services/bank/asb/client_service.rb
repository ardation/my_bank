class Bank::Asb::ClientService
  def initialize
    login
  end

  def accounts
    response = client.get("https://secure.anz.co.nz/IBCS/service/api/customers/#{customer_id}")
    JSON.parse(response.body)['accounts']
  end

  def transactions(account_id, start_date = Time.zone.today.beginning_of_month, end_date = Time.zone.today)
    response = client.get(
      'https://secure.anz.co.nz/IBCS/service/api/transactions',
      transaction_query(account_id, start_date, end_date)
    )
    JSON.parse(response.body)['transactions']
  end

  protected

  def client
    return @client if @client

    @client = Mechanize.new
    @client.user_agent_alias = 'Mac Safari'
    @client
  end

  def login
    page = client.get('https://online.asb.co.nz/auth')
    form = page.form_with(name: 'login')
    form.field_with(name: 'dUsername').value = ENV.fetch('ASB_USER_ID')
    form.field_with(name: 'username').value = ENV.fetch('ASB_USER_ID')
    form.field_with(name: 'password').value = ENV.fetch('ASB_PASSWORD')
    page = client.submit(form)
    page
  end

  def transaction_query(account_id, start_date, end_date)
    {
      account: account_id,
      ascending: false,
      order: 'postdate',
      from: start_date.strftime('%Y-%m-%d'),
      to: end_date.strftime('%Y-%m-%d')
    }
  end
end
