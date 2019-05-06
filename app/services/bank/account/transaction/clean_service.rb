class Bank::Account::Transaction::CleanService
  def self.clean
    Bank::Account::Transaction.where(
      Bank::Account::Transaction.arel_table[:date].lt(Time.zone.today.beginning_of_month)
    ).delete_all
  end
end
