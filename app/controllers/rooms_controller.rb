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
  before_action :validate_accepted_terms, unless: -> { !Rails.configuration.terms }
  before_action :validate_verified_email, unless: -> { !Rails.configuration.enable_email_verification }
  before_action :find_room, except: :create
  before_action :verify_room_ownership, except: [:create, :show, :join, :logout]

  META_LISTED = "gl-listed"

  # POST /
  def create
    redirect_to root_path unless current_user

    @room = Room.new(name: room_params[:name])
    @room.owner = current_user

    if @room.save
      if room_params[:auto_join] == "1"
        start
      else
        redirect_to @room
      end
    end
  end

  # GET /:room_uid
  def show
    if current_user && @room.owned_by?(current_user)
      @recordings = @room.recordings
      @is_running = @room.running?
    else
      render :join
    end
  end

  # PATCH /:room_uid
  def update
    if params[:setting] == "rename_block"
      @room = Room.find_by!(uid: params[:room_block_uid])
      update_room_attributes
    elsif params[:setting] == "rename_header"
      update_room_attributes
    elsif params[:setting] == "rename_recording"
      @room.update_recording(params[:record_id], "meta_name" => params[:record_name])
    end
    redirect_to room_path
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

    if @room.running?
      # Determine if the user needs to join as a moderator.
      opts[:user_is_moderator] = @room.owned_by?(current_user)

      if current_user
        redirect_to @room.join_path(current_user.name, opts, current_user.uid)
      else
        join_name = params[:join_name] || params[@room.invite_path][:join_name]
        redirect_to @room.join_path(join_name, opts)
      end
    else
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

    redirect_to @room.join_path(current_user.name, opts, current_user.uid)

    # Notify users that the room has started.
    # Delay 5 seconds to allow for server start, although the request will retry until it succeeds.
    NotifyUserWaitingJob.set(wait: 5.seconds).perform_later(@room)
  end

  # GET /:room_uid/logout
  def logout
    # Redirect the correct page.
    redirect_to @room
  end

  # POST /:room_uid/:record_id
  def update_recording
    meta = {
      "meta_#{META_LISTED}" => (params[:state] == "public"),
    }

    res = @room.update_recording(params[:record_id], meta)
    redirect_to @room if res[:updated]
  end

  # DELETE /:room_uid/:record_id
  def delete_recording
    @room.delete_recording(params[:record_id])

    redirect_to current_user.main_room
  end

  # Helper for converting BigBlueButton dates into the desired format.
  def recording_date(date)
    date.strftime("%B #{date.day.ordinalize}, %Y.")
  end
  helper_method :recording_date

  # Helper for converting BigBlueButton dates into a nice length string.
  def recording_length(playbacks)
    # Stats format currently doesn't support length.
    valid_playbacks = playbacks.reject { |p| p[:type] == "statistics" }
    return "0 min" if valid_playbacks.empty?

    len = valid_playbacks.first[:length]
    if len > 60
      "#{(len / 60).round} hrs"
    elsif len == 0
      "< 1 min"
    else
      "#{len} min"
    end
  end
  helper_method :recording_length

  # Prevents single images from erroring when not passed as an array.
  def safe_recording_images(images)
    Array.wrap(images)
  end
  helper_method :safe_recording_images

  private

  def update_room_attributes
    if @room.owned_by?(current_user) && @room != current_user.main_room
      @room.update_attributes(name: params[:room_name])
    end
  end

  def room_params
    params.require(:room).permit(:name, :auto_join)
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
      redirect_to resend_path unless current_user.email_verified
    end
  end
end
