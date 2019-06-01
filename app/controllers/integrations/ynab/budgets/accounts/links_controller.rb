class Integrations::Ynab::Budgets::Accounts::LinksController < Integrations::Ynab::Budgets::AccountsController
  before_action :load_account

  def create
    build_link
    return if save_link

    redirect_to integration_path(@link.integration)
  end

  def destroy
    load_link
    @link.destroy
    redirect_to integration_path(@link.integration)
    flash[:warning] = 'Bank to Budget Link disconnected successfully.'
  end

  protected

  def load_link
    @link ||= link_scope.find(params[:link_id] || params[:id])
  end

  def build_link
    @link ||= link_scope.build
    @link.attributes = link_params
  end

  def save_link
    return false unless @link.save

    redirect_to integration_path(@link.integration)
    flash[:success] = 'Bank to Budget Link added successfully. Please allow 10 minutes for My Bank to sync your data.'
    true
  end

  def link_params
    bank_params = params[:integration_ynab_budget_account_link]
    bank_params ? bank_params.permit(:bank_account_id) : {}
  end

  def link_scope
    @account.links
  end
end
