class Bank::Account::Transaction < ApplicationRecord
  belongs_to :account,
             class_name: 'Bank::Account'
end
