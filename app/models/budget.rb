class Budget < ApplicationRecord
  has_many :accounts, class_name: 'Budget::Account', dependent: :destroy
end
