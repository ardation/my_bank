class Integrations::Ynab::Budgets::AccountsController < Integrations::Ynab::BudgetsController
  before_action :load_budget

  protected

  def load_account
    @account ||= account_scope.find(params[:account_id] || params[:id])
  end

  def account_scope
    @budget.accounts
  end
end
