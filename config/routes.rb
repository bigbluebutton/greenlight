Rails.application.routes.draw do

  # Room and Meeting routes.
  scope '/rooms' do
    scope '/:room_uid' do
      get '/', to: 'rooms#index', as: :room
      resources :meetings, only: [:index, :show, :create], param: :meeting_uid
      match '/meetings/:meeting_uid/join', to: 'meetings#join', as: :join_meeting, via: [:get, :post]
      match '/meetings/:meeting_uid/wait', to: 'meetings#wait', as: :wait_meeting, via: [:get, :post]
    end
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