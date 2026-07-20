# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with Greenlight; if not, see <http://www.gnu.org/licenses/>.

# frozen_string_literal: true

class AddRecordingsAccessCode < ActiveRecord::Migration[7.0]
  def up
    # 1. Create the MeetingOption for glRecordingsAccessCode
    meeting_option = MeetingOption.create!(name: 'glRecordingsAccessCode', default_value: '')
    
    # 2. Add the option to the RoomsConfigurations
    provider_name = 'greenlight'
    
    # Check if the entry already exists
    unless RoomsConfiguration.exists?(provider: provider_name, meeting_option_id: meeting_option.id)
      RoomsConfiguration.create!(
        provider: provider_name,
        meeting_option_id: meeting_option.id,
        value: 'optional' # optional means that the setting can be changed by the user
      )
    end
  end

  def down
    # Find the MeetingOption for glRecordingsAccessCode
    meeting_option = MeetingOption.find_by(name: 'glRecordingsAccessCode')
    
    if meeting_option
      provider_name = 'greenlight'
      
      # Delete all room settings for this option
      RoomMeetingOption.joins(:meeting_option)
                      .where(meeting_options: { name: 'glRecordingsAccessCode' })
                      .destroy_all
      
      # Remove from RoomsConfigurations
      RoomsConfiguration.where(provider: provider_name, meeting_option_id: meeting_option.id).destroy_all
      
      # Delete the MeetingOption
      meeting_option.destroy
    end
  end
end
