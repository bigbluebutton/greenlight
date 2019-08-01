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
# with BigBlueButton; if not, see <http://www.gnu.org/licenses/>

class RecordingsController < ApplicationController
  before_action :find_room
  before_action :verify_room_ownership

  META_LISTED = "gl-listed"

  # POST /:meetingID/:record_id
  def update_recording
    meta = {
      "meta_#{META_LISTED}" => (params[:state] == "public"),
    }

    res = @room.update_recording(params[:record_id], meta)

    # Redirects to the page that made the initial request
    redirect_to request.referrer if res[:updated]
  end

  # DELETE /:meetingID/:record_id
  def delete_recording
    @room.delete_recording(params[:record_id])

    # Redirects to the page that made the initial request
    redirect_to request.referrer
  end

  private

  def find_room
    @room = Room.find_by!(bbb_id: params[:meetingID])
  end

  # Ensure the user is logged into the room they are accessing.
  def verify_room_ownership
    if !current_user || (!@room.owned_by?(current_user) &&
           !current_user.highest_priority_role.can_edit_site_settings &&
           !current_user.has_role?(:super_admin))
      redirect_to root_path
    end
  end
end
