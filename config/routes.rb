Rails.application.routes.draw do

  # Room routes.
  scope '/r/:room_uid' do
    get '/', to: 'rooms#show', as: :room
    match '/start', to: 'rooms#start', as: :start_room, via: [:get, :post]
    match '/join', to: 'rooms#join', as: :join_room, via: [:get, :post]
    match '/wait', to: 'rooms#wait', as: :wait_room, via: [:get, :post]
    match '/logout', to: 'rooms#logout', as: :logout_room, via: [:get, :post]
    get '/sessions', to: 'rooms#sessions', as: :sessions
  end

  # Meeting routes.
  scope '/m' do
    post '/', to: 'meetings#create', as: :create_meeting
    get '/:meeting_uid', to: 'meetings#show', as: :meeting
    post '/:meeting_uid', to: 'meetings#join', as: :join_meeting
  end

  # Signup routes.
  get '/signup', to: 'users#new'
  post '/signup', to: 'users#create'

  # Handles login of greenlight provider accounts.
  post '/login',  to: 'sessions#create', as: :create_session

  # Login to Greenlight.
  get '/login', to: 'sessions#new'

  # Log the user out of the session.
  get '/logout', to: 'sessions#destroy'

  # Handles launches from a trusted launcher.
  post '/launch', to: 'sessions#launch'

  # Handles Omniauth authentication.
  match '/auth/:provider/callback', to: 'sessions#omniauth', via: [:get, :post], as: :omniauth_session
  get '/auth/failure', to: 'sessions#fail'

  root to: 'main#index'
end
