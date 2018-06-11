Rails.application.routes.draw do

  # Error routes.
  match '/404', to: 'errors#not_found', via: :all
  match '/422', to: 'errors#unprocessable', via: :all
  match '/500', to: 'errors#internal_error', via: :all

  # Room resources.
  resources :rooms, only: [:create, :show, :destroy], param: :room_uid, path: '/r'

  # Extended room routes.
  scope '/r/:room_uid' do
    post '/', to: 'rooms#join'
    post '/start', to: 'rooms#start', as: :start_room
    get '/logout', to: 'rooms#logout', as: :logout_room
    post '/home', to: 'rooms#home', as: :make_home
    
    # Mange recordings.
    scope '/:record_id' do
      post '/', to: 'rooms#update_recording', as: :update_recording
      delete '/', to: 'rooms#delete_recording', as: :delete_recording
    end
  end

  # User resources.
  get '/signup', to: 'users#new', as: :signup
  post '/signup', to: 'users#create', as: :create_user
  get '/users/:user_uid/edit', to: 'users#edit', as: :edit_user
  patch '/users/:user_uid/edit', to: 'users#update', as: :update_user

  # Handles login of greenlight provider accounts.
  post '/login',  to: 'sessions#create', as: :create_session

  # Log the user out of the session.
  get '/logout', to: 'sessions#destroy'

  # Handles launches from a trusted launcher.
  post '/launch', to: 'sessions#launch'

  # Handles Omniauth authentication.
  match '/auth/:provider/callback', to: 'sessions#omniauth', via: [:get, :post], as: :omniauth_session
  get '/auth/failure', to: 'sessions#fail'

  root to: 'main#index'
end
