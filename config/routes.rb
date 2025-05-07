# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with Greenlight; if not, see <http://www.gnu.org/licenses/>.

# frozen_string_literal: true

Rails.application.routes.draw do
  root 'components#index', via: :all
  mount ActionCable.server => '/cable'

  # External requests
  get '/auth/:provider/callback', to: 'external#create_user'
  get '/meeting_ended', to: 'external#meeting_ended'
  post '/recording_ready', to: 'external#recording_ready'

  # Health checks
  get '/health_check', to: 'health_checks#check'

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
      resources :rooms, param: :friendly_id do
        member do
          get '/recordings', to: 'rooms#recordings'
          get '/public_recordings', to: 'rooms#public_recordings'
          get '/recordings_processing', to: 'rooms#recordings_processing'
          get '/public', to: 'rooms#public_show'
          delete :purge_presentation
        end
      end
      resources :meetings, only: %i[], param: :friendly_id do
        member do
          post '/start', to: 'meetings#start'
          post '/status', to: 'meetings#status'
          get '/running', to: 'meetings#running'
        end
      end
      resources :room_settings, only: %i[show update], param: :friendly_id
      resources :recordings, only: %i[index update destroy] do
        collection do
          post '/update_visibility', to: 'recordings#update_visibility'
          get '/recordings_count', to: 'recordings#recordings_count'
          post '/recording_url', to: 'recordings#recording_url'
        end
      end
      resources :shared_accesses, only: %i[create show destroy], param: :friendly_id do
        member do
          get '/shareable_users', to: 'shared_accesses#shareable_users'
          post '/unshare_room', to: 'shared_accesses#unshare_room'
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
      resources :site_settings, only: :index
      resources :rooms_configurations, only: %i[index show], param: :name
      resources :locales, only: %i[index show], param: :name
      resources :server_tags, only: :show, param: :friendly_id do
        collection do
          get '/fallback_mode', to: 'server_tags#fallback_mode'
        end
      end

      namespace :admin do
        resources :users, only: %i[update] do
          collection do
            get '/verified', to: 'users#verified'
            get '/unverified', to: 'users#unverified'
            get '/pending', to: 'users#pending'
            get '/banned', to: 'users#banned'
            post '/:user_id/create_server_room', to: 'users#create_server_room'
          end
        end
        resources :server_recordings, only: %i[index]
        resources :server_rooms, only: %i[index destroy], param: :friendly_id do
          get '/resync', to: 'server_rooms#resync', on: :member
        end
        resources :site_settings, only: %i[index update], param: :name do
          collection do
            delete '/', to: 'site_settings#purge_branding_image'
          end
        end
        resources :rooms_configurations, only: :update, param: :name
        resources :roles
        resources :invitations, only: %i[index create destroy]
        resources :role_permissions, only: [:index] do
          collection do
            post '/', to: 'role_permissions#update'
          end
        end
        resources :tenants, only: %i[index create destroy]
      end

      namespace :migrations do
        post '/roles', to: 'external#create_role'
        post '/users', to: 'external#create_user'
        post '/rooms', to: 'external#create_room'
        post '/settings', to: 'external#create_settings'
      end
    end
  end


  match '*path', to: 'components#index', via: :all, constraints: lambda { |req|
    req.path.exclude? 'rails/active_storage'
  } # Enable CSR for full fledged http requests.
end
