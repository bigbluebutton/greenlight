Rails.application.routes.draw do
  resources :users, only: [:edit, :update]

  # This should be removed once before being released
  get '/auth/:provider/callback', to: 'sessions#create'
  ###########################################################

  get '/users/auth/:provider/callback', to: 'sessions#create'
  get '/users/logout', to: 'sessions#destroy', as: :user_logout
  get '/meetings/join/:resource/:id', to: 'bbb#join', as: :bbb_join
  get '/meetings/new', to: 'landing#new_meeting', as: :new_meeting

  # There are two resources [meetings|rooms]
  # meetings offer a landing page for NON authenticated users to create and join session in BigBlueButton
  # rooms offer a customized landing page for authenticated users to create and join session in BigBlueButton
  get '/:resource(/:id)', to: 'landing#index', as: :resource

  root to: 'landing#meeting', :resource => "meetings"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
