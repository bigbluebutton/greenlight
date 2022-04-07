# frozen_string_literal: true

Rails.application.routes.draw do
  root 'components#index', via: :all

  # All the Api endpoints must be under /api/v1 and must have an extension .json.
  namespace :api do
    namespace :v1 do
      resources :sessions, only: %i[index create] do
        collection do
          delete 'signout', to: 'sessions#destroy'
        end
      end
      resources :users, only: [:create]
      resources :rooms, only: %i[show index], param: :friendly_id
    end
  end
  match '*path', to: 'components#index', via: :all # Enable CSR for full fledged http requests.
end
