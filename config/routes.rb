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
  get 'help/getting_started', as: :help

  mount ActionCable.server => '/cable'

  resources :users, only: [:edit, :update]
  get '/users/login', to: 'sessions#new', as: :user_login
  get '/users/logout', to: 'sessions#destroy', as: :user_logout

  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  get '/auth/failure', to: 'landing#auth_failure'

  # There are two resources [meetings|rooms]
  # meetings offer a landing page for NON authenticated users to create and join session in BigBlueButton
  # rooms offer a customized landing page for authenticated users to create and join session in BigBlueButton
  scope '/:resource', constraints: {resource: /meetings|rooms/} do

    # room specific routes
    scope '/:room_id' do
      # recording routes for updating, deleting and viewing recordings
      get '/(:id)/recordings', to: 'bbb#recordings', defaults: {id: nil, format: 'json'}
      patch '/(:id)/recordings/:record_id', to: 'bbb#update_recordings', defaults: {id: nil, format: 'json'}
      delete '/(:id)/recordings/:record_id', to: 'bbb#delete_recordings', defaults: {id: nil, format: 'json'}

      delete '/:id/end', to: 'bbb#end', defaults: {format: 'json'}
      get '/:id/wait', to: 'landing#wait_for_moderator'
      get '/:id/session_status_refresh', to: 'landing#session_status_refresh'
    end
    post '/:room_id/:id/callback', to: 'bbb#callback' #, defaults: {format: 'json'}

    # routes shared between meetings and rooms
    get '/(:room_id)/:id/join', to: 'bbb#join', defaults: {room_id: nil, format: 'json'}
    get '/(:room_id)/:id', to: 'landing#resource', as: :meeting_room, defaults: {room_id: nil}
  end

  root to: 'landing#index', :resource => 'meetings'
end
