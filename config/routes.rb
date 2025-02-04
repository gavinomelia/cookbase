Rails.application.routes.draw do
  resources :recipe_books, only: [:new, :create, :index, :show]
  resources :users, only: [:new, :create]
  resources :password_resets, only: [:create, :new, :edit, :update]
  
  # Session routes for login/logout
  get '/login', to: 'sessions#new', as: :login
  post '/login', to: 'sessions#create'
  get '/logout', to: 'sessions#destroy', as: :logout

  # Recipe routes
 resources :recipes do
    collection do
      post 'scrape'
      get :search
    end
  member do
    get :scale
  end
end
  # Root route
  root "pages#index"
end

