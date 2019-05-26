Rails.application.routes.draw do
  devise_for :users
  get '/auth/:provider/callback', to: 'sessions#create'
end
