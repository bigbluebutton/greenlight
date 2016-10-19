Rails.application.routes.draw do
  get 'bbb/join/:resource/:id', to: 'bbb#join', as: :bbb_join

  get '/meetings/new', to: 'landing#new_meeting', as: :new_meeting
  get '/meetings(/:id)', to: 'landing#meeting', as: :meeting, :resource => "meetings"
  get '/rooms/:name', to: 'landing#room', as: :room, :resource => "rooms"

  get '/auth/:provider/callback', to: 'sessions#create'
  get '/logout', to: 'sessions#destroy'

  root to: 'landing#meeting', :resource => "meetings"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
