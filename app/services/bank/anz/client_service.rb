class Bank::Anz::ClientService
  attr_reader :bank, :token

  def initialize(bank)
    @bank = bank
    login
  end

  def accounts(start_date, end_date)
    response = client.get("https://secure.anz.co.nz/IBCS/service/api/customers/#{customer_id}")
    JSON.parse(response.body)['accounts'].map do |remote_account|
      begin
        ofx_account = ofx_transactions(remote_account['id'], start_date, end_date).account
      rescue StandardError
        Rails.logger.info('no transactions found')
      end
      json_account = json_transactions(remote_account['id'], start_date, end_date) unless ofx_account
      { ofx_account: ofx_account, json_account: json_account, anz_account: remote_account }
    end
  end

  def logout
    client.get('https://secure.anz.co.nz/IBCS/service/goodbye')
  end

  protected

  def ofx_transactions(account_id, start_date, end_date)
    response = JSON.parse(
      client.post(
        'https://secure.anz.co.nz/IBCS/service/account/export-transactions',
        ofx_transaction_query(account_id, start_date, end_date).to_json,
        'Content-Type' => 'application/json',
        'X-CSRFToken' => token
      ).body
    )
    return unless response['success']

    ofx_file = client.get("https://secure.anz.co.nz#{response['downloadUrl']}")
    OFX(ofx_file.body)
  end

  def json_transactions(account_id, start_date, end_date)
    response = client.get(
      'https://secure.anz.co.nz/IBCS/service/api/transactions',
      json_transaction_query(account_id, start_date, end_date),
      nil,
      'Content-Type' => 'application/json',
      'X-CSRFToken' => token
    )
    JSON.parse(response.body)['transactions']
  end

  def client
    return @client if @client

    @client = Mechanize.new
    @client.cookie_jar << Mechanize::Cookie.new(domain: '.anz.co.nz', name: 'IBCookieDetect', value: '1', path: '/')
    @client
  end

  def login
    response = client.post(
      'https://digital.anz.co.nz/preauth/web/service/login',
      login_body,
      'Content-Type' => 'application/json'
    )
    page = client.get(JSON.parse(response.body)['location'])
    search = page.search('script').text.scan(/IBPage\.sessionCsrfToken = \"(.*)\";/)
    @token = search[0][0]
  rescue StandardError => e
    Rollbar.error(e)
    raise Bank::AuthenticationError
  end

  def customer_id
    response = client.get('https://secure.anz.co.nz/IBCS/service/home/initialise')
    JSON.parse(response.body)['currentCustomerUuid']
  end

  def login_body
    {
      firstPage: '', password: encrypt(bank.password), publicKeyId: public_key['publicKeyId'], userId: bank.username
    }.to_json
  end

  def ofx_transaction_query(account_id, start_date, end_date)
    {
      accountUuid: account_id,
      exportFormat: 'OFX',
      fromDate: start_date.strftime('%Y-%m-%d'),
      includeColumnHeadings: true,
      sortAscending: false,
      sortColumn: 'postdate',
      toDate: end_date.strftime('%Y-%m-%d')
    }
  end

  def json_transaction_query(account_id, start_date, end_date)
    [
      ['account', account_id],
      ['ascending', false],
      ['from', start_date.strftime('%Y-%m-%d')],
      %w[order trandate],
      ['to', end_date.strftime('%Y-%m-%d')]
    ]
  end

  def public_key
    @public_key ||= HTTParty.get('https://digital.anz.co.nz/preauth/web/api/v1/publickeys/current').parsed_response
  end

  def encrypt(string)
    key = OpenSSL::PKey::RSA.new("-----BEGIN PUBLIC KEY-----\n#{public_key['publicKey']}\n-----END PUBLIC KEY-----")
    Base64.encode64(key.public_encrypt(string)).squish
  end
end
