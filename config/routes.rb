Rails.application.routes.draw do
  resources :users, only: [:edit, :update]
  get '/users/logout', to: 'sessions#destroy', as: :user_logout

  get '/auth/:provider/callback', to: 'sessions#create'

  # There are two resources [meetings|rooms]
  # meetings offer a landing page for NON authenticated users to create and join session in BigBlueButton
  # rooms offer a customized landing page for authenticated users to create and join session in BigBlueButton
  get '/:resource(/:id)', to: 'landing#index', as: :resource
  get '/:resource/:id/join', to: 'bbb#join', as: :bbb_join, defaults: { :format => 'json' }

  root to: 'landing#index', :resource => "meetings"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
