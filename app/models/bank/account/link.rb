class Bank::Account::Link < ApplicationRecord
  belongs_to :bank_account,
             class_name: 'Bank::Account'
  belongs_to :budget_account,
             class_name: 'Budget::Account'
end
