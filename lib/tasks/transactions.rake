namespace :transactions do
  desc 'remove historic transactions'
  task clean: :environment do
    Bank::Account::Transaction::CleanService.clean
  end
end
