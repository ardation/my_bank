class Integrations::Ynab::BudgetsController < IntegrationsController
  before_action :load_integration

  protected

  def load_budget
    @budget ||= budget_scope.find(params[:budget_id] || params[:id])
  end

  def budget_scope
    @integration.budgets
  end
end
