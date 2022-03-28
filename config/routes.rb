# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  root 'components#index'
  # All the Api endpoints must be under /api/v1 and must have an extension .json.
  namespace :api do
    namespace :v1 do
      resources :users, only: [:create]
      resources :rooms, only: [:show], param: :friendly_id
    end
  end
  match '*path', to: 'components#index', via: :all # Enable CSR for full fledged http requests.
end
