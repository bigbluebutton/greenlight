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

  resources :users, only: [:edit, :update]
  get '/users/login', to: 'sessions#new'
  get '/users/logout', to: 'sessions#destroy', as: :user_logout

  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  get '/auth/failure', to: 'landing#auth_failure'

  # There are two resources [meetings|rooms]
  # meetings offer a landing page for NON authenticated users to create and join session in BigBlueButton
  # rooms offer a customized landing page for authenticated users to create and join session in BigBlueButton

  patch '/rooms/:room_id/recordings/:record_id', to: 'bbb#update_recordings', defaults: {format: 'json'}
  delete '/rooms/:room_id/recordings/:record_id', to: 'bbb#delete_recordings', defaults: {format: 'json'}


  get '/rooms/:room_id',  to: 'landing#resource', resource: 'rooms'
  get '/rooms/:room_id/recordings', to: 'bbb#recordings', defaults: {format: 'json'}
  get '/rooms/:room_id/:id', to: 'landing#resource', resource: 'rooms'
  delete '/rooms/:room_id/:id/end', to: 'bbb#end', defaults: {format: 'json'}
  get '/rooms/:room_id/:id/recordings', to: 'bbb#recordings', defaults: {format: 'json'}
  patch '/rooms/:room_id/:id/recordings/:record_id', to: 'bbb#update_recordings', defaults: {format: 'json'}
  delete '/rooms/:room_id/:id/recordings/:record_id', to: 'bbb#delete_recordings', defaults: {format: 'json'}

  get '/:resource/:id', to: 'landing#resource', as: :resource
  get '/:resource/:id/join', to: 'bbb#join', as: :bbb_join, defaults: {format: 'json'}
  post '/:resource/:id/callback', to: 'bbb#callback' #, defaults: {format: 'json'}

  get '/:resource/:room_id/:id/wait', to: 'landing#wait_for_moderator'
  get '/:resource/:room_id/:id/session_status_refresh', to: 'landing#session_status_refresh'
  get '/:resource/:room_id/:id/join', to: 'bbb#join', defaults: {format: 'json'}


  root to: 'landing#index', :resource => 'meetings'
end
