if Rails.env.production?
  Rollbar.configure do |config|
    config.access_token = Rails.application.credentials.rollbar.try(:[], :access_token)
  end
end
