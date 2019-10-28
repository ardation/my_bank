class Integration::Ynab < Integration
  has_many :budgets,
           class_name: 'Integration::Ynab::Budget',
           dependent: :destroy,
           foreign_key: 'integration_id',
           inverse_of: :integration

  def access_token
    return credentials['token'] if Time.now.in_time_zone < Time.at(credentials['expires_at']).in_time_zone

    update_refresh_token
  end

  protected

  def update_refresh_token
    response = refresh_token_request
    update(credentials: {
             'token' => response['access_token'],
             'refresh_token' => response['refresh_token'],
             'expires_at' => response['created_at'] + response['expires_in'],
             'expires' => true
           })
    credentials['token']
  end

  def refresh_token_request
    query = {
      client_id: Rails.application.credentials.ynab[:id],
      client_secret: Rails.application.credentials.ynab[:secret],
      grant_type: 'refresh_token',
      refresh_token: credentials['refresh_token']
    }
    HTTParty.post("https://app.youneedabudget.com/oauth/token?#{query.to_query}").parsed_response
  end
end
