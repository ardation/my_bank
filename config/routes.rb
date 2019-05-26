Rails.application.routes.draw do
  devise_for :users
  get '/auth/:provider/callback', to: 'sessions#create'

  resources :banks do
    scope module: :banks do
      resources :accounts do
        scope module: :accounts do
          resources :transactions
        end
      end
    end
  end

  root to: 'application#index'
end
