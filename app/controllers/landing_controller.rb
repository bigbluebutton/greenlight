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

class LandingController < ApplicationController
  include BbbApi

  def index
  end

  def resource
    if params[:resource] == 'meetings'
      render_meeting
    elsif params[:resource] == 'rooms'
      render_room
    else
      render 'errors/error'
    end
  end

  def wait_for_moderator
    render layout: false
  end

  def session_status_refresh
    @user = User.find_by(encrypted_id: params[:id])
    if @user.nil?
      render head(:not_found) && return
    end

    @meeting_running = bbb_get_meeting_info(@user.encrypted_id)[:returncode]

    render layout: false
  end

  def auth_failure
    redirect_to '/'
  end

  def admin?
    @user && @user == current_user
  end
  helper_method :admin?

  private

  def render_meeting
    @meeting_id = params[:id]
    params[:action] = 'meetings'
    render :action => 'meetings'
  end

  def render_room
    params[:action] = 'rooms'

    @user = User.find_by(encrypted_id: params[:id])
    if @user.nil?
      redirect_to root_path
      return
    end

    @meeting_running = bbb_get_meeting_info(@user.encrypted_id)[:returncode]

    render :action => 'rooms'
  end

end
