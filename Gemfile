source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.1'

gem 'attr_encrypted', '~> 3.1.0'
gem 'awesome_rails_console'
gem 'bootsnap', '>= 1.4.2', require: false
gem 'devise'
gem 'devise-bootstrap-views', '~> 1.0'
gem 'httparty'
gem 'mechanize'
gem 'ofx'
gem 'omniauth'
gem 'omniauth-ynab'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 3.11'
gem 'rails', '~> 6.0.0.rc1'
gem 'sass-rails', '~> 5'
gem 'turbolinks', '~> 5'
gem 'webpacker', '~> 4.0'

group :development do
  gem 'foreman'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'rubocop'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
  gem 'letter_opener'
end

group :development, :test do
  gem 'dotenv-rails'
  gem 'hirb'
  gem 'hirb-unicode-steakknife', require: 'hirb-unicode'
  gem 'pry-byebug'
  gem 'pry-stack_explorer'
  gem 'rspec-rails', '~> 3.8'
end

group :test do
  gem 'factory_bot'
end
