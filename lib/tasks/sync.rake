namespace :sync do
  desc 'sync all data from ANZ and YNAB'
  task recent: :environment do
    Anz::PullService.pull
    Ynab::PullService.pull
    Ynab::PushService.push
  end
end
