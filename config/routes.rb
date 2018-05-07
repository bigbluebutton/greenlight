Rails.application.routes.draw do

  scope '/rooms' do
    scope '/:room_uid' do
      get '/', to: 'rooms#index', as: :room
      resources :meetings, only: [:index, :show, :create], param: :meeting_uid
      match '/meetings/:meeting_uid/join', to: 'meetings#join', as: :join_meeting, via: [:get, :post]
      match '/meetings/:meeting_uid/wait', to: 'meetings#wait', as: :wait_meeting, via: [:get, :post]
    end
  end

  get '/login', to: 'sessions#new', as: :user_login
  get '/logout', to: 'sessions#destroy', as: :user_logout

  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  get '/auth/failure', to: 'sessions#fail'

  root to: 'main#index'
end