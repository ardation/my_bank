Rails.application.config.middleware.use OmniAuth::Builder do
  provider :ynab, ENV.fetch('YNAB_ID'), ENV.fetch('YNAB_SECRET')
end
