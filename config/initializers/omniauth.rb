Rails.application.config.middleware.use OmniAuth::Builder do
  provider :ynab, Rails.application.credentials.ynab.try(:[], :id), Rails.application.credentials.ynab.try(:[], :secret)
end
