# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2016 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.

# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  mount ActionCable.server => '/cable'

  match '/404', to: 'errors#not_found', via: :all
  match '/500', to: 'errors#error', via: :all
  match '/422', to: 'errors#error', via: :all

  resources :users, only: [:edit, :update]
  get '/users/login', to: 'sessions#new', as: :user_login
  get '/users/logout', to: 'sessions#destroy', as: :user_logout

  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  get '/auth/failure', to: 'sessions#auth_failure'

  # There are two resources [meetings|rooms]
  # meetings offer a landing page for NON authenticated users to create and join session in BigBlueButton
  # rooms offer a customized landing page for authenticated users to create and join session in BigBlueButton
  scope '/:resource', constraints: {resource: /meetings|rooms/} do
    disallow_slash = /[^\/]+/ # override the constraint to allow '.' and disallow '/'
    # room specific routes
    scope '/:room_id', :constraints => {:room_id => disallow_slash} do
      # recording routes for updating, deleting and viewing recordings
      get '/(:id)/recordings', to: 'bbb#recordings', defaults: {id: nil, format: 'json'}, :constraints => {:id => disallow_slash}
      get '/(:id)/recordings/can_upload', to: 'bbb#can_upload', defaults: {id: nil, format: 'json'}, :constraints => {:id => disallow_slash}
      post '/(:id)/recordings/:record_id', to: 'bbb#youtube_publish', defaults: {id: nil, format: 'json'}, :constraints => {:id => disallow_slash}
      patch '/(:id)/recordings/:record_id', to: 'bbb#update_recordings', defaults: {id: nil, format: 'json'}, :constraints => {:id => disallow_slash}
      delete '/(:id)/recordings/:record_id', to: 'bbb#delete_recordings', defaults: {id: nil, format: 'json'}, :constraints => {:id => disallow_slash}

      delete '/:id/end', to: 'bbb#end', defaults: {format: 'json'}, :constraints => {:id => disallow_slash}
      get '/:id/wait', to: 'landing#wait_for_moderator', :constraints => {:id => disallow_slash}
      get '/:id/session_status_refresh', to: 'landing#session_status_refresh', :constraints => {:id => disallow_slash}
    end
    post '/:room_id/:id/callback', to: 'bbb#callback', :constraints => {:id => disallow_slash, :room_id => disallow_slash}

    # routes shared between meetings and rooms
    get '/(:room_id)/:id/join', to: 'bbb#join', defaults: {room_id: nil, format: 'json'}, :constraints => {:id => disallow_slash, :room_id => disallow_slash}
    get '/(:room_id)/:id', to: 'landing#resource', as: :meeting_room, defaults: {room_id: nil}, :constraints => {:id => disallow_slash, :room_id => disallow_slash}
  end

  get '/preferences', to: 'landing#preferences', as: :preferences

  root to: 'landing#index', :resource => 'meetings'
end
