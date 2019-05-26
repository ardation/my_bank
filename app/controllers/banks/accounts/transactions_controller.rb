class Banks::Accounts::TransactionsController < Banks::AccountsController
  decorates_assigned :transactions, :transaction
  before_action :load_account
  breadcrumb -> { account.name }, -> { bank_account_path bank, account }
  breadcrumb 'Transactions', -> { bank_account_transactions_path bank, account }

  def index
    load_transactions
  end

  def show
    load_transaction
  end

  def new
    build_transaction
  end

  def create
    build_transaction
    save_transaction || render('new')
  end

  def edit
    load_transaction
    build_transaction
  end

  def update
    load_transaction
    build_transaction
    save_transaction || render('edit')
  end

  def destroy
    load_transaction
    @transaction.destroy
  end

  protected

  def load_transactions
    @transactions ||= transaction_scope.page params[:page]
  end

  def load_transaction
    @transaction ||= transaction_scope.find(params[:transaction_id] || params[:id])
  end

  def build_transaction
    @transaction ||= transaction_scope.build
    @transaction.attributes = transaction_params
  end

  def save_transaction
    redirect_to transaction_path(@transaction) if @transaction.save
  end

  def transaction_params
    transaction_params = params[:transaction]
    transaction_params ? transaction_params.permit(:username, :password, :type) : {}
  end

  def transaction_scope
    @account.transactions
  end
end
