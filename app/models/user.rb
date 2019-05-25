class User < ApplicationRecord
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :timeoutable, :trackable

  has_many :banks, dependent: :destroy
end
