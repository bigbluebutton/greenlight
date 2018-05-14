Rails.application.routes.draw do

  # Room and Meeting routes.
  scope '/rooms/:room_uid' do
    get '/', to: 'rooms#index', as: :room
    match '/join', to: 'rooms#join', as: :join_room, via: [:get, :post]
    match '/wait', to: 'rooms#wait', as: :wait_room, via: [:get, :post]
    resources :meetings, only: [:index], param: :meeting_uid
  end

  # Signup routes.
  get '/signup', to: 'users#new'
  post '/signup', to: 'users#create'

  # Handles login of :greenlight provider account.
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