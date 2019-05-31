class BankDecorator < ApplicationDecorator
  decorates_association :accounts

  def service
    Bank::TYPES.invert[type]
  end
end
