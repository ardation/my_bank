Rails.application.routes.draw do
  devise_for :users
  get '/auth/:provider', to: ->(_env) { [404, {}, ['Not Found']] }, as: :auth
  get '/auth/:provider/callback', to: 'sessions#create'

  resources :banks do
    scope module: :banks do
      resources :accounts, only: %i[index show] do
        scope module: :accounts do
          resources :transactions, only: :index
        end
      end
    end
  end

  resources :integrations do
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
