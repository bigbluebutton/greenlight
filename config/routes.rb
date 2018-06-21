Rails.application.routes.draw do

  # Error routes.
  match '/404', to: 'errors#not_found', via: :all
  match '/422', to: 'errors#unprocessable', via: :all
  match '/500', to: 'errors#internal_error', via: :all

  # Signup routes.
  get '/signup', to: 'users#new', as: :signup
  post '/signup', to: 'users#create', as: :create_user

  # User resources.
  scope '/u' do
    match '/terms', to: 'users#terms', via: [:get, :post]

    # Handles login of greenlight provider accounts.
    post '/login',  to: 'sessions#create', as: :create_session
  
    # Log the user out of the session.
    get '/logout', to: 'sessions#destroy'

    get '/:user_uid/edit', to: 'users#edit', as: :edit_user
    patch '/:user_uid/edit', to: 'users#update', as: :update_user
  end

  # Handles launches from a trusted launcher.
  post '/launch', to: 'sessions#launch'

  # Handles Omniauth authentication.
  match '/auth/:provider/callback', to: 'sessions#omniauth', via: [:get, :post], as: :omniauth_session
  get '/auth/failure', to: 'sessions#fail'

  # Room resources.
  resources :rooms, only: [:create, :show, :destroy], param: :room_uid, path: '/'

  # Extended room routes.
  scope '/:room_uid' do
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

  root to: 'main#index'
end
