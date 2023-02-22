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

class PopulateRoomsConfigurations < ActiveRecord::Migration[7.0]
  def up
    RoomsConfiguration.create! [
      { meeting_option: MeetingOption.find_by(name: 'record'), value: 'optional', provider: 'greenlight' },
      { meeting_option: MeetingOption.find_by(name: 'muteOnStart'), value: 'optional', provider: 'greenlight' },
      { meeting_option: MeetingOption.find_by(name: 'guestPolicy'), value: 'optional', provider: 'greenlight' },
      { meeting_option: MeetingOption.find_by(name: 'glAnyoneCanStart'), value: 'optional', provider: 'greenlight' },
      { meeting_option: MeetingOption.find_by(name: 'glAnyoneJoinAsModerator'), value: 'optional', provider: 'greenlight' },
      { meeting_option: MeetingOption.find_by(name: 'glRequireAuthentication'), value: 'optional', provider: 'greenlight' },
      { meeting_option: MeetingOption.find_by(name: 'glViewerAccessCode'), value: 'optional', provider: 'greenlight' },
      { meeting_option: MeetingOption.find_by(name: 'glModeratorAccessCode'), value: 'optional', provider: 'greenlight' }
    ]
  end

  def down
    RoomsConfiguration.destroy_all
  end
end
