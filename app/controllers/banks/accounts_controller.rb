class Banks::AccountsController < BanksController
  decorates_assigned :accounts, :account
  before_action :load_bank
  breadcrumb -> { "#{bank.name} #{bank.username}" }, -> { bank_path bank }
  breadcrumb 'Accounts', -> { bank_accounts_path bank }

  def index
    load_accounts
  end

  def show
    load_account
    redirect_to bank_account_transactions_path(@bank, @account)
  end

  protected

  def load_accounts
    @accounts ||= account_scope.order(:name).page params[:page]
  end

  def load_account
    @account ||= account_scope.find(params[:account_id] || params[:id])
  end

  def account_scope
    @bank.accounts
  end
end
