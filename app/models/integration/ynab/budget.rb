class Integration::Ynab::Budget < ApplicationRecord
  self.table_name = 'integration_ynab_budgets'

  belongs_to :integration
  has_many :accounts,
           class_name: 'Integration::Ynab::Budget::Account',
           dependent: :destroy
end
