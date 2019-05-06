class Anz::ClientService
  attr_reader :csrf_token

  def client
    return @client if @client

    @client = Mechanize.new
    @client.cookie_jar << Mechanize::Cookie.new(domain: '.anz.co.nz', name: 'IBCookieDetect', value: '1', path: '/')
    @client
  end

  def login
    file = client.post(
      'https://digital.anz.co.nz/preauth/web/service/login', login_query, 'Content-Type' => 'application/json'
    )
    get_session(JSON.parse(file.body)['location'])
  end

  def logout
    client.get('https://secure.anz.co.nz/IBCS/service/goodbye') if csrf_token
    @csrf_token = nil
  end

  def customer_id
    client.get('https://secure.anz.co.nz/IBCS/service/home/initialise')
    binding.pry
  end

  protected

  def login_query
    {
      firstPage: '',
      password: encrypt(ENV.fetch('ANZ_PASSWORD')),
      publicKeyId: public_key['publicKeyId'],
      userId: ENV.fetch('ANZ_USER_ID')
    }.to_json
  end

  def public_key
    @public_key ||= HTTParty.get('https://digital.anz.co.nz/preauth/web/api/v1/publickeys/current').parsed_response
  end

  def encrypt(string)
    key = OpenSSL::PKey::RSA.new("-----BEGIN PUBLIC KEY-----\n#{public_key['publicKey']}\n-----END PUBLIC KEY-----")
    Base64.encode64(key.public_encrypt(string)).squish
  end

  def get_session(session_url)
    file = client.get(session_url).parser.to_s
    @csrf_token = file.match(/IBPage\.sessionCsrfToken = "(\w*)"/i).captures[0]
  end
end
