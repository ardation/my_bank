namespace :transactions do
  desc 'remove historic transactions'
  task clean: :environment do
    Bank::Account::Transaction::CleanService.clean if Time.now.in_time_zone.day == 1
  end
end
