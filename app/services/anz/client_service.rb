class Anz::ClientService
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

  def logout
    client.get('https://secure.anz.co.nz/IBCS/service/goodbye')
  end

  protected

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
    client.get(JSON.parse(response.body)['location'])
  end

  def customer_id
    response = client.get('https://secure.anz.co.nz/IBCS/service/home/initialise')
    JSON.parse(response.body)['currentCustomerUuid']
  end

  def login_body
    {
      firstPage: '',
      password: encrypt(ENV.fetch('ANZ_PASSWORD')),
      publicKeyId: public_key['publicKeyId'],
      userId: ENV.fetch('ANZ_USER_ID')
    }.to_json
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

  def public_key
    @public_key ||= HTTParty.get('https://digital.anz.co.nz/preauth/web/api/v1/publickeys/current').parsed_response
  end

  def encrypt(string)
    key = OpenSSL::PKey::RSA.new("-----BEGIN PUBLIC KEY-----\n#{public_key['publicKey']}\n-----END PUBLIC KEY-----")
    Base64.encode64(key.public_encrypt(string)).squish
  end
end
