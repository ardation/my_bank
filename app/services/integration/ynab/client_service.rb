class Integration::Ynab::ClientService
  include HTTParty
  base_uri 'api.youneedabudget.com'

  def initialize(integration)
    @options = { headers: { 'Authorization' => "Bearer #{integration.access_token}" }, format: :json }
  end

  def budgets
    self.class.get('/v1/budgets', @options).parsed_response['data']['budgets']
  end

  def accounts(budget_id)
    self.class.get("/v1/budgets/#{budget_id}/accounts", @options).parsed_response['data']['accounts']
  end

  def create_transactions(budget_id, transactions)
    self.class.post("/v1/budgets/#{budget_id}/transactions", @options.merge(body: { transactions: transactions }))
  end
end
