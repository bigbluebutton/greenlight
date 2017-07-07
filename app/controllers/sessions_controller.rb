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

class SessionsController < ApplicationController

  skip_before_action :verify_authenticity_token

  def new
    # If LDAP is enabled, just route to it instead.
    if Rails.application.config.omniauth_ldap
      redirect_to "#{relative_root}/auth/ldap"
    end
  end

  def create
    @user = User.from_omniauth(request.env['omniauth.auth'])
    session[:user_id] = @user.id
    redirect_to meeting_room_url(resource: 'rooms', id: @user.encrypted_id)
  rescue => e
    logger.error "Error authenticating via omniauth: #{e}"
    redirect_to root_path
  end

  def destroy
    if current_user
      session.delete(:user_id)
    end
    redirect_to root_path
  end

  def auth_failure
    puts params.inspect
    if params[:message] == 'invalid_credentials'
      redirect_to '/', flash: {danger: t('invalid_login') }
    elsif params[:message] == 'ldap_error'
      redirect_to '/', flash: {danger: t('ldap_error') }
    else
      redirect_to '/'
    end
  end
end
