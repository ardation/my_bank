class Bank::Account::TransactionDecorator < ApplicationDecorator
  def amount
    Money.new(object.amount.to_f * 100, object.account.currency || 'USD')
  end
end
