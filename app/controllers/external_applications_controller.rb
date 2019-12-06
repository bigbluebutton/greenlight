# frozen_string_literal: true

# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2018 BigBlueButton Inc. and by respective authors (see below).
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

require 'net/http'

class ExternalApplicationsController < ApplicationController

  skip_before_action :verify_authenticity_token, only: [:start, :http_options]
  before_action :token_to_omniauth_user, only: [:start]
  before_action :set_user, only: [:start]
  before_action :set_server_url, only: [:start]

  # POST /external_applications/start
  def start
    add_allow_credentials_headers
    respond_to do |format|
      format.json {
        render json: { server_url: @server_url, code: @oauth_response_code }
      }
    end
  end

  # OPTIONS /external_applications/start
  def http_options
    add_allow_credentials_headers
    head :ok
  end

  # GET /external_applications/auto_close
  def auto_close
  end

  private

    def add_allow_credentials_headers
      # TODO: allow only headers stored internally
      response.headers['Access-Control-Allow-Origin'] = request.headers['Origin'] || '*'
      response.headers['Access-Control-Allow-Credentials'] = 'true'
      response.headers['Access-Control-Allow-Headers'] = 'accept, content-type'
    end 

    def token_to_omniauth_user
      token = params[:oauth_token]
      if token.present?
        uri = URI.parse("https://www.googleapis.com/oauth2/v1/userinfo?alt=json&access_token=" + token)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        request = Net::HTTP::Get.new(uri.request_uri)
        request.add_field 'Authorization', 'Bearer ' + token
        request['Accept'] = 'application/json'
        request.body = nil
        
        response = http.request(request)

        @oauth_response_code = response.code.to_i
        @omniauth_user = JSON.parse(response.body)
      else
        @oauth_response_code = 500
      end
    end

    def set_user
      if @oauth_response_code == 200
        @auth = {
            'provider' => 'google',
            'uid' => @omniauth_user['id'],
            'info' => @omniauth_user,
        }
        @auth['info']['image'] = @omniauth_user['picture']
        @user = User.from_omniauth(@auth)
      end
    end

    def set_server_url
      if @oauth_response_code == 200
        @room = @user.main_room
        @server_url = @room.join_path(@user.name, room_opts, @user.uid)
      elsif @oauth_response_code == 500
        @server_url = internal_error_url
      else
        @server_url = unauthorized_url
      end
    end

    def room_opts
      # Join the user in and start the meeting.
      opts = default_meeting_options
      opts[:user_is_moderator] = true
      opts[:meeting_logout_url] = auto_close_url

      # Include the user's choices for the room settings
      room_settings = JSON.parse(@room[:room_settings])
      opts[:mute_on_start] = room_settings["muteOnStart"] if room_settings["muteOnStart"]
      opts[:require_moderator_approval] = room_settings["requireModeratorApproval"]
      opts
    end
end