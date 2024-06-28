Rails.application.routes.draw do
  # User registration routes
  resources :users, only: [:new, :create]
  resources :password_resets, only: [:create, :new, :edit, :update]
  
  # Session routes for login/logout
  get '/login', to: 'sessions#new', as: :login
  post '/login', to: 'sessions#create'
  get '/logout', to: 'sessions#destroy', as: :logout

  # Recipe routes
  resources :recipes

  # Root route
  root "recipes#index"
end

