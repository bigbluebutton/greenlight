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

desc 'Server Recordings sync with BBB server'

task server_recordings_sync: :environment do
  Recording.destroy_all

  Room.select(:id, :meeting_id).in_batches(of: 25) do |rooms|
    meeting_ids = rooms.pluck(:meeting_id)

    recordings = BigBlueButtonApi.new.get_recordings(meeting_ids:)
    recordings[:recordings].each do |recording|
      RecordingCreator.new(recording:).call
    end
  end
end
