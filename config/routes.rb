require 'sidekiq/web'
require 'sidekiq/cron/web'
require 'sidekiq_unique_jobs/web'

Sidekiq::Web.set :session_secret, Rails.application.credentials.try(:[], :secret_key_base)

Rails.application.routes.draw do
  devise_for :users
  authenticate :user, ->(user) { Rails.env.development? || user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end
  get '/auth/:provider', to: ->(_env) { [404, {}, ['Not Found']] }, as: :auth
  get '/auth/:provider/callback', to: 'sessions#create'

  resources :banks do
    member do
      get :sync
    end
    scope module: :banks do
      resources :accounts, only: %i[index show] do
        scope module: :accounts do
          resources :transactions, only: :index
        end
      end
    end
  end

  resources :integrations do
    member do
      get :sync
    end
    scope module: :integrations do
      namespace :ynab do
        resources :budgets, only: [] do
          scope module: :budgets do
            resources :accounts, only: [] do
              scope module: :accounts do
                resources :links, only: %i[create destroy]
              end
            end
          end
        end
      end
    end
  end
end
