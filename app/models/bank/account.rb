class Bank::Account < ApplicationRecord
  belongs_to :bank
  has_many :transactions,
           class_name: 'Bank::Account::Transaction',
           dependent: :destroy
  has_many :links,
           class_name: 'Integration::Ynab::Budget::Account::Link',
           dependent: :destroy,
           foreign_key: 'bank_account_id',
           inverse_of: :bank_account
end
