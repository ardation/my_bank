class Bank::Account < ApplicationRecord
  has_many :transactions, class_name: 'Bank::Account::Transaction', dependent: :destroy
end
