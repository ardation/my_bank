class Integration::Ynab::Budget::Account::Link < ApplicationRecord
  belongs_to :bank_account,
             class_name: 'Bank::Account'
  belongs_to :budget_account,
             class_name: 'Integration::Ynab::Budget::Account'
  validates :budget_account_id, uniqueness: { scope: [:bank_account_id] }

  delegate :integration, to: :budget_account
end
