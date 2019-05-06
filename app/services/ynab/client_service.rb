class Ynab::ClientService
  include HTTParty
  base_uri 'api.youneedabudget.com'

  def initialize
    @options = { headers: { 'Authorization' => "Bearer #{ENV.fetch('YNAB_ACCESS_TOKEN')}" }, format: :json }
  end

  def budgets
    self.class.get('/v1/budgets', @options).parsed_response['data']['budgets']
  end

  def accounts(budget_id)
    self.class.get("/v1/budgets/#{budget_id}/accounts", @options).parsed_response['data']['accounts']
  end
end
