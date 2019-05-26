class Banks::AccountsController < BanksController
  decorates_assigned :accounts, :account
  before_action :load_bank
  breadcrumb -> { bank.name }, -> { bank_path bank }
  breadcrumb 'Accounts', -> { bank_accounts_path bank }

  def index
    load_accounts
  end

  def show
    load_account
    redirect_to bank_account_transactions_path(@bank, @account)
  end

  def new
    build_account
  end

  def create
    build_account
    save_account || render('new')
  end

  def edit
    load_account
    build_account
  end

  def update
    load_account
    build_account
    save_account || render('edit')
  end

  def destroy
    load_account
    @account.destroy
  end

  protected

  def load_accounts
    @accounts ||= account_scope.page params[:page]
  end

  def load_account
    @account ||= account_scope.find(params[:account_id] || params[:id])
  end

  def build_account
    @account ||= account_scope.build
    @account.attributes = account_params
  end

  def save_account
    redirect_to account_path(@account) if @account.save
  end

  def account_params
    account_params = params[:account]
    account_params ? account_params.permit(:username, :password, :type) : {}
  end

  def account_scope
    @bank.accounts
  end
end
