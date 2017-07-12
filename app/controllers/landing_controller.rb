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
    redirect_to user_login_path if Rails.configuration.disable_guest_access
  end

  def resource
    if Rails.configuration.disable_guest_access && params[:resource] == 'meetings'
      redirect_to user_login_path 
    else
      if params[:id].size > meeting_name_limit
        redirect_to root_url, flash: {danger: t('meeting_name_long')}
      elsif ['&', '$', ','].any? { |c| params[:id].include?(c) } # temporary fix for misbehaving characters
        redirect_to root_url, flash: {danger: t('disallowed_characters_msg')}
      elsif params[:resource] == 'meetings' && !params[:room_id]
        render_meeting
      elsif params[:resource] == 'rooms'
        render_room
      else
        redirect_to root_url, flash: {danger: t('error')}
      end
    end
  end

  def send_meetings_data
    render json: {active: bbb.get_meetings, waiting: WaitingList.waiting}
  end

  def wait_for_moderator
    WaitingList.add(params[:room_id], params[:name], params[:id])
    ActionCable.server.broadcast 'refresh_meetings',
      method: 'waiting',
      meeting: params[:id],
      room: params[:room_id],
      user: params[:name]
    render layout: false
  end

  def no_longer_waiting
    WaitingList.remove(params[:room_id], params[:name], params[:id])
    ActionCable.server.broadcast 'refresh_meetings',
      method: 'no_longer_waiting',
      meeting: params[:id],
      room: params[:room_id],
      user: params[:name]
  end

  def session_status_refresh
    @user = User.find_by(encrypted_id: params[:room_id])
    if @user.nil?
      render head(:not_found) && return
    end

    @meeting_id = params[:id]
    @meeting_running = bbb_get_meeting_info("#{@user.encrypted_id}-#{params[:id]}")[:returncode]

    render layout: false
  end

  def admin?
    @user && @user == current_user
  end
  helper_method :admin?

  def preferences
    @user = current_user
  end

  def landing_background
    if !current_user || !current_user.background? then
      (ENV['LANDING_BACKGROUND'].present?) ? ENV['LANDING_BACKGROUND'] : 'greenlight_background.png'
    else
      current_user.background.url
    end
  end
  helper_method :landing_background

  private

  def render_meeting
    @meeting_id = params[:id].strip
    params[:action] = 'meetings'
    render :action => 'meetings'
  end

  def render_room
    params[:action] = 'rooms'

    @user = User.find_by(encrypted_id: params[:room_id] || params[:id])
    if @user.nil?
      redirect_to root_path
      return
    end

    if @user.encrypted_id != params[:id]
      @meeting_id = params[:id].strip
    end
    @meeting_running = bbb_get_meeting_info("#{@user.encrypted_id}-#{@meeting_id}")[:returncode]
    @main_room = @meeting_id.blank? || @meeting_id == @user.encrypted_id

    render :action => 'rooms'
  end

end
