# frozen_string_literal: true

Rails.application.routes.draw do
  root 'components#index'

  # All the Api endpoints must be under /api/v1 and must have an extension .json.
  namespace :api do
    namespace :v1 do
      resources :users, only: [:create]
      resources :rooms, only: [:show], param: :friendly_id
      resources :sessions, only: %i[create destroy] do
        collection do
          get 'signed_in', to: 'sessions#signed_in'
        end
      end
    end
  end
  match '*path', to: 'components#index', via: :all # Enable CSR for full fledged http requests.
end
