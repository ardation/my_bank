class Bank::Account < ApplicationRecord
  has_many :transactions,
           class_name: 'Bank::Account::Transaction',
           dependent: :destroy
  has_many :links,
           class_name: 'Bank::Account::Link',
           dependent: :destroy,
           foreign_key: 'bank_account_id',
           inverse_of: :bank_account
end
