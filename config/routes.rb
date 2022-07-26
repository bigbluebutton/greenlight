# frozen_string_literal: true

Rails.application.routes.draw do
  root 'components#index', via: :all
  mount ActionCable.server => '/cable'

  # External requests
  get '/auth/:provider/callback', to: 'external#create_user'
  get '/meeting_ended', to: 'external#meeting_ended'
  post '/recording_ready', to: 'external#recording_ready'

  # All the Api endpoints must be under /api/v1 and must have an extension .json.
  namespace :api do
    namespace :v1 do
      resources :sessions, only: %i[index create] do
        collection do
          delete 'signout', to: 'sessions#destroy'
        end
      end
      resources :users, only: %i[show create update destroy] do
        post '/change_password', to: 'users#change_password', on: :collection
        member do
          delete :purge_avatar
        end
      end
      resources :rooms, only: %i[show index create update destroy], param: :friendly_id do
        member do
          get '/recordings', to: 'rooms#recordings'
          get '/recordings_processing', to: 'rooms#recordings_processing'
          delete :purge_presentation
          get '/access_codes', to: 'rooms#access_codes'
          patch '/generate_access_code', to: 'rooms#generate_access_code'
          patch '/remove_access_code', to: 'rooms#remove_access_code'
        end
      end
      resources :meetings, only: %i[], param: :friendly_id do
        member do
          post '/start', to: 'meetings#start'
          get '/join', to: 'meetings#join'
        end
      end
      resources :room_settings, only: %i[show update], param: :friendly_id
      resources :recordings, only: %i[index update destroy] do
        collection do
          get '/resync', to: 'recordings#resync'
          post '/update_visibility', to: 'recordings#update_visibility'
        end
      end
      resources :shared_accesses, only: %i[create show destroy], param: :friendly_id do
        member do
          get '/shareable_users', to: 'shared_accesses#shareable_users'
        end
      end
      resources :env, only: :index
      resources :reset_password, only: :create do
        collection do
          post '/reset', to: 'reset_password#reset'
          post '/verify', to: 'reset_password#verify'
        end
      end
      resources :verify_account, only: :create do
        post '/activate', to: 'verify_account#activate', on: :collection
      end
      resources :site_settings, only: :show, param: :name
      resources :rooms_configurations, only: :index

      namespace :admin do
        resources :users, only: %i[create destroy]  do
          collection do
            get '/active_users', to: 'users#active_users'
            post '/:user_id/create_server_room', to: 'users#create_server_room'
          end
        end
        resources :server_rooms, only: %i[index destroy], param: :friendly_id
        resources :server_recordings, only: %i[index]
        resources :site_settings, only: %i[index update], param: :name
        resources :rooms_configurations, only: :update, param: :name
        resources :roles
      end
    end
  end


  match '*path', to: 'components#index', via: :all, constraints: lambda { |req|
    req.path.exclude? 'rails/active_storage'
  } # Enable CSR for full fledged http requests.
end
