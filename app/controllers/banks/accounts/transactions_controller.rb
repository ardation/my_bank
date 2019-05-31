class Banks::Accounts::TransactionsController < Banks::AccountsController
  decorates_assigned :transactions, :transaction
  before_action :load_account
  breadcrumb -> { account.name }, -> { bank_account_path bank, account }
  breadcrumb 'Transactions', -> { bank_account_transactions_path bank, account }

  def index
    load_transactions
  end

  protected

  def load_transactions
    @transactions ||= transaction_scope.page params[:page]
  end

  def transaction_scope
    @account.transactions
  end
end
