namespace :sync do
  desc 'sync all data with remote sources'
  task recent: :environment do
    Bank.find_each(&:sync)
    Integration.find_each(&:sync)
  end
end
