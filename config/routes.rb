Rails.application.routes.draw do
  get 'bbb/join/:id', to: 'bbb#join', as: :bbb_join

  get '/meeting/new', to: 'landing#new_meeting', as: :new_meeting
  get '/meeting(/:id)', to: 'landing#index', as: :landing, :resource => "meeting"
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/logout', to: 'sessions#destroy'
  get '/rooms/:name', to: 'landing#room'

  root to: 'landing#index', :resource => "meeting"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
