class Bank::AccountDecorator < ApplicationDecorator
  def name
    object.nickname || object.name
  end

  def balance
    Money.new(object.balance.to_f * 100, object.currency || 'USD')
  end

  def available_balance
    Money.new(object.available_balance.to_f * 100, object.currency || 'USD')
  end
end
