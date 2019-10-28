Rails.application.config.middleware.use OmniAuth::Builder do
  provider :ynab, Rails.application.credentials.ynab[:id], Rails.application.credentials.ynab[:secret]
end
