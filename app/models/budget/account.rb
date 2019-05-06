class Budget::Account < ApplicationRecord
  belongs_to :budget
  has_many :links,
           class_name: 'Bank::Account::Link',
           dependent: :destroy,
           foreign_key: 'budget_account_id',
           inverse_of: :budget_account
  has_many :bank_accounts,
           through: :links
  has_many :transactions,
           through: :bank_accounts
end
