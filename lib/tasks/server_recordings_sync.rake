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
task :recordings_sync, %i[provider] => :environment do |_task, args|
  args.with_defaults(provider: 'greenlight')

  Room.includes(:user).select(:id, :meeting_id).with_provider(args[:provider]).in_batches(of: 25) do |rooms|
    meeting_ids = rooms.pluck(:meeting_id)

    recordings = BigBlueButtonApi.new(provider: args[:provider]).get_recordings(meeting_ids:)
    recordings[:recordings].each do |recording|
      RecordingCreator.new(recording:).call
      success 'Successfully migrated Recording:'
      info "RecordID: #{recording[:recordID]}"
    rescue StandardError => e
      err "Unable to migrate Recording:\nRecordID: #{recording[:recordID]}\nError: #{e}"
    end
  end
end

task :recordings_check, %i[provider] => :environment do |_task, args|
  args.with_defaults(provider: 'greenlight')
  recent_rooms = Room.with_provider(args[:provider]).where(last_session: 1.hour.ago..Time.now)
end
