namespace :sync do
  desc 'sync all data with remote sources'
  task recent: :environment do
    Bank.find_each do |bank|
      bank.sync
    rescue StandardError => e
      Rails.logger.error [e.message, *e.backtrace].join($INPUT_RECORD_SEPARATOR)
    end
    Integration.find_each do |integration|
      integration.sync
    rescue StandardError => e
      Rails.logger.error [e.message, *e.backtrace].join($INPUT_RECORD_SEPARATOR)
    end
  end
  task bank_last_two_years: :environment do
    Bank.find_each do |bank|
      bank.sync(2.years.ago)
    rescue StandardError => e
      Rails.logger.error [e.message, *e.backtrace].join($INPUT_RECORD_SEPARATOR)
    end
  end
end
