# frozen_string_literal: true

Rails.application.routes.draw do
  root 'components#index', via: :all
  mount ActionCable.server => '/cable'

  # All the Api endpoints must be under /api/v1 and must have an extension .json.
  namespace :api do
    namespace :v1 do
      resources :sessions, only: %i[index create] do
        collection do
          delete 'signout', to: 'sessions#destroy'
        end
      end
      resources :users, only: %i[index create update destroy] do
        member do
          delete :purge_avatar
        end
      end
      resources :rooms, only: %i[show index create destroy], param: :friendly_id do
        member do
          post '/start', to: 'rooms#start', as: :start_meeting
          get '/recordings', to: 'rooms#recordings'
          get '/join', to: 'rooms#join'
          get '/status', to: 'rooms#status'
        end
      end
      resources :room_settings, only: %i[show update], param: :friendly_id
      resources :recordings, only: [:index] do
        collection do
          get '/recordingsReSync', to: 'recordings#recordings'
        end
      end
      resources :shared_accesses, only: %i[create show destroy], path: '/shared_accesses/room', param: :friendly_id do
          member do
            get '/shareable_users', to: 'shared_accesses#shareable_users'
          end
      end
      resources :recordings, only: [:index]
    end
  end
  match '*path', to: 'components#index', via: :all, constraints: lambda { |req|
    req.path.exclude? 'rails/active_storage'
  } # Enable CSR for full fledged http requests.
end
