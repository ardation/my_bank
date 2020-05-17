require 'sidekiq/api'

redis_config = { url: ENV['REDIS_URL'] }

Sidekiq.configure_server do |config|
  config.redis = redis_config

  config.death_handlers << lambda { |job, _ex|
    digest = job['unique_digest']
    SidekiqUniqueJobs::Digests.delete_by_digest(digest) if digest
  }
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end

require 'sidekiq/web'
Sidekiq::Web.app_url = '/'

schedule_file = 'config/schedule.yml'
Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file) if File.exist?(schedule_file) && Sidekiq.server?
