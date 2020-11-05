require 'faraday_middleware'
require 'faraday_middleware/aws_sigv4'

class Bank::Simplicity::ClientService
  attr_reader :bank, :credentials

  def initialize(bank)
    @bank = bank
    @unit_price = {}
    login
  end

  def logout; end

  def accounts
    client.post(
      '/prod/secure',
      {
        operationName: nil,
        variables: {},
        query: "{\nAccount(email: \"#{bank.username}\") {\nInvestmentType\nInvestmentCode\n"\
               "InvestmentName\nPortfolio\nPortfolioCode\nMarketValue\n}\n}\n"
      }.to_json
    ).body['data']['Account']
  end

  def transactions(account)
    client.post(
      '/prod/secure',
      {
        operationName: nil,
        variables: {},
        query: "{\nTransactions(id: \"#{account.remote_id}\", portfolioCode: \"#{account.remote_bank_id}\")\n}\n"
      }.to_json
    ).body['data']['Transactions']['items']
  end

  def unit_price(account)
    @unit_price[account.remote_id] ||= {}
    @unit_price[account.remote_id][account.remote_bank_id] ||= client.post(
      '/prod/secure',
      {
        operationName: nil,
        variables: {},
        query: "{\nSummary(id: \"#{account.remote_id}\", portfolioCode: \"#{account.remote_bank_id}\", "\
              "startDate: \"#{start_date(account)}\", endDate: \"#{end_date(account)}\") {\nUnits }\n}\n"
      }.to_json
    ).body['data']['Summary']['Units']['UnitPrice'].to_f
  end

  protected

  def start_date(account)
    client.post(
      '/prod/secure',
      {
        operationName: nil,
        variables: {},
        query: "{\nGetJoinDate(id: \"#{account.remote_id}\", portfolioCode: \"#{account.remote_bank_id}\") "\
               "{\ndate }\n}\n"
      }.to_json
    ).body['data']['GetJoinDate']['date']
  end

  def end_date(_account)
    Time.zone.now.strftime('%Y-%m-%dT00:00:00')
  end

  def client
    @client ||= Faraday.new(url: 'https://h4ku5ofov2.execute-api.ap-southeast-2.amazonaws.com') do |faraday|
      faraday.request(
        :aws_sigv4, service: 'execute-api', region: 'ap-southeast-2', access_key_id: credentials['AccessKeyId'],
                    secret_access_key: credentials['SecretKey'], session_token: credentials['SessionToken']
      )
      faraday.response :json, content_type: /\bjson\b/
      faraday.response :raise_error
      faraday.adapter Faraday.default_adapter
    end
  end

  def browser
    @browser ||= Watir::Browser.new :chrome, options: { args: ['window-size=1920,1080'] }, headless: true
  end

  def login
    browser.goto('https://app.simplicity.kiwi/login')
    return unless browser.title == 'Simplicity App - Simplicity NZ Ltd'

    browser.text_field(id: 'email').set bank.username
    browser.text_field(id: 'password').set bank.password
    browser.button(type: 'submit').click
    local_storage = browser.h3(text: 'Accounts').wait_until_present.execute_script('return window.localStorage')
    fetch_credentials(local_storage)
  rescue StandardError => e
    Rollbar.error(e)
    raise Bank::AuthenticationError
  ensure
    browser.close
  end

  def fetch_credentials(local_storage)
    @credentials = JSON.parse(
      HTTParty.post(
        'https://cognito-identity.ap-southeast-2.amazonaws.com/',
        {
          body: credential_request_body(local_storage),
          headers: {
            'Content-Type' => 'application/x-amz-json-1.1',
            'x-amz-target' => 'AWSCognitoIdentityService.GetCredentialsForIdentity'
          }
        }
      ).response.body
    )['Credentials']
  end

  def credential_request_body(local_storage)
    {
      'Logins' => {
        local_storage[
          "aws.cognito.identity-providers.ap-southeast-2:0ed33fc6-4cef-4f2e-b634-31c616e108e2#{bank.username}"
        ] => local_storage["CognitoIdentityServiceProvider.kvoiu7unft0c8hqqsa6hkmeu5.#{bank.username}.idToken"]
      },
      'IdentityId' => local_storage[
        "aws.cognito.identity-id.ap-southeast-2:0ed33fc6-4cef-4f2e-b634-31c616e108e2#{bank.username}"
      ]
    }.to_json
  end
end
