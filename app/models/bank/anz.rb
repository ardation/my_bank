class Bank::Anz < Bank
  validates :username, :password, presence: true
end
