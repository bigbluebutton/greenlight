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

class RoomsController < ApplicationController
  include RecordingsHelper
  include Pagy::Backend

  before_action :validate_accepted_terms, unless: -> { !Rails.configuration.terms }
  before_action :validate_verified_email, except: [:show, :join],
                unless: -> { !Rails.configuration.enable_email_verification }
  before_action :find_room, except: :create
  before_action :verify_room_ownership, except: [:create, :show, :join, :logout]
  before_action :verify_room_owner_verified, only: [:show, :join],
                unless: -> { !Rails.configuration.enable_email_verification }
  before_action :verify_user_not_admin, only: [:show]

  # POST /
  def create
    redirect_to(root_path) && return unless current_user

    @room = Room.new(name: room_params[:name])
    @room.owner = current_user
    @room.room_settings = create_room_settings_string(room_params[:mute_on_join], room_params[:client])

    if @room.save
      if room_params[:auto_join] == "1"
        start
      else
        flash[:success] = I18n.t("room.create_room_success")
        redirect_to @room
      end
    else
      flash[:alert] = I18n.t("room.create_room_error")
      redirect_to current_user.main_room
    end
  end

  # GET /:room_uid
  def show
    if current_user && @room.owned_by?(current_user)
      @search, @order_column, @order_direction, recs =
        @room.recordings(params.permit(:search, :column, :direction), true)

      @pagy, @recordings = pagy_array(recs)

      @is_running = @room.running?
    else
      # Get users name
      @name = if current_user
        current_user.name
      elsif cookies.encrypted[:greenlight_name]
        cookies.encrypted[:greenlight_name]
      else
        ""
      end

      @search, @order_column, @order_direction, pub_recs =
        @room.public_recordings(params.permit(:search, :column, :direction), true)

      @pagy, @public_recordings = pagy_array(pub_recs)

      render :join
    end
  end

  # PATCH /:room_uid
  def update
    if params[:setting] == "rename_block"
      @room = Room.find_by!(uid: params[:room_block_uid])
      update_room_attributes("name")
    elsif params[:setting] == "rename_header"
      update_room_attributes("name")
    elsif params[:setting] == "rename_recording"
      @room.update_recording(params[:record_id], "meta_name" => params[:record_name])
    end

    if request.referrer
      redirect_to request.referrer
    else
      redirect_to room_path
    end
  end

  # POST /:room_uid
  def join
    opts = default_meeting_options
    unless @room.owned_by?(current_user)
      # Assign join name if passed.
      if params[@room.invite_path]
        @join_name = params[@room.invite_path][:join_name]
      elsif !params[:join_name]
        # Join name not passed.
        return
      end
    end

    # create or update cookie with join name
    cookies.encrypted[:greenlight_name] = @join_name unless cookies.encrypted[:greenlight_name] == @join_name

    if @room.running? || @room.owned_by?(current_user)
      # Determine if the user needs to join as a moderator.
      opts[:user_is_moderator] = @room.owned_by?(current_user)

      # Check if the user has specified which client to use
      room_settings = JSON.parse(@room[:room_settings])
      opts[:join_via_html5] = room_settings["joinViaHtml5"] if room_settings["joinViaHtml5"]

      if current_user
        redirect_to @room.join_path(current_user.name, opts, current_user.uid)
      else
        join_name = params[:join_name] || params[@room.invite_path][:join_name]
        redirect_to @room.join_path(join_name, opts)
      end
    else

      search_params = params[@room.invite_path] || params
      @search, @order_column, @order_direction, pub_recs =
        @room.public_recordings(search_params.permit(:search, :column, :direction), true)

      @pagy, @public_recordings = pagy_array(pub_recs)

      # They need to wait until the meeting begins.
      render :wait
    end
  end

  # DELETE /:room_uid
  def destroy
    # Don't delete the users home room.
    @room.destroy if @room.owned_by?(current_user) && @room != current_user.main_room

    redirect_to current_user.main_room
  end

  # POST /:room_uid/start
  def start
    # Join the user in and start the meeting.
    opts = default_meeting_options
    opts[:user_is_moderator] = true

    # Include the user's choices for the room settings
    room_settings = JSON.parse(@room[:room_settings])
    opts[:mute_on_start] = room_settings["muteOnStart"] if room_settings["muteOnStart"]
    opts[:join_via_html5] = room_settings["joinViaHtml5"] if room_settings["joinViaHtml5"]

    begin
      redirect_to @room.join_path(current_user.name, opts, current_user.uid)
    rescue BigBlueButton::BigBlueButtonException => e
      redirect_to room_path, alert: I18n.t(e.key.to_s.underscore, default: I18n.t("bigbluebutton_exception"))
    end

    # Notify users that the room has started.
    # Delay 5 seconds to allow for server start, although the request will retry until it succeeds.
    NotifyUserWaitingJob.set(wait: 5.seconds).perform_later(@room)
  end

  # POST /:room_uid/update_settings
  def update_settings
    begin
      raise "Room name can't be blank" if room_params[:name].empty?

      @room = Room.find_by!(uid: params[:room_uid])
      # Update the rooms settings
      update_room_attributes("settings")
      # Update the rooms name if it has been changed
      update_room_attributes("name") if @room.name != room_params[:name]
    rescue StandardError
      flash[:alert] = I18n.t("room.update_settings_error")
    else
      flash[:success] = I18n.t("room.update_settings_success")
    end
    redirect_to room_path
  end

  # GET /:room_uid/logout
  def logout
    # Redirect the correct page.
    redirect_to @room
  end

  private

  def update_room_attributes(update_type)
    if @room.owned_by?(current_user) && @room != current_user.main_room
      if update_type.eql? "name"
        @room.update_attributes(name: params[:room_name] || room_params[:name])
      elsif update_type.eql? "settings"
        room_settings_string = create_room_settings_string(room_params[:mute_on_join], room_params[:client])
        @room.update_attributes(room_settings: room_settings_string)
      end
    end
  end

  def create_room_settings_string(mute_res, client_res)
    room_settings = {}
    room_settings["muteOnStart"] = mute_res == "1"

    if client_res.eql? "html5"
      room_settings["joinViaHtml5"] = true
    elsif client_res.eql? "flash"
      room_settings["joinViaHtml5"] = false
    end

    room_settings.to_json
  end

  def room_params
    params.require(:room).permit(:name, :auto_join, :mute_on_join, :client)
  end

  # Find the room from the uid.
  def find_room
    @room = Room.find_by!(uid: params[:room_uid])
  end

  # Ensure the user is logged into the room they are accessing.
  def verify_room_ownership
    bring_to_room unless @room.owned_by?(current_user)
  end

  # Redirects a user to their room.
  def bring_to_room
    if current_user
      # Redirect authenticated users to their room.
      redirect_to room_path(current_user.main_room)
    else
      # Redirect unauthenticated users to root.
      redirect_to root_path
    end
  end

  def validate_accepted_terms
    if current_user
      redirect_to terms_path unless current_user.accepted_terms
    end
  end

  def validate_verified_email
    if current_user
      redirect_to account_activation_path(current_user) unless current_user.activated?
    end
  end

  def verify_room_owner_verified
    unless @room.owner.activated?
      flash[:alert] = t("room.unavailable")

      if current_user && !@room.owned_by?(current_user)
        redirect_to current_user.main_room
      else
        redirect_to root_path
      end
    end
  end

  def verify_user_not_admin
    redirect_to admins_path if current_user && current_user&.has_role?(:super_admin)
  end
end
