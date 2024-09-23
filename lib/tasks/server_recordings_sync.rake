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

task :server_recordings_sync, %i[provider] => :environment do |_task, args|
  args.with_defaults(provider: 'greenlight')

  Room.select do |room|
    room_recordings = room.recordings
    Format.where(recording: room_recordings).delete_all
    room_recordings.delete_all
  end

  Room.includes(:user).select(:id, :meeting_id).with_provider(args[:provider]).in_batches(of: 25) do |rooms|
    meeting_ids = rooms.pluck(:meeting_id)

    recordings = BigBlueButtonApi.new(provider: args[:provider]).get_recordings(meeting_ids:)

    rooms.update_all(recordings_processing: 0) # rubocop:disable Rails/SkipsModelValidations

    next if recordings[:recordings].blank?

    recordings[:recordings].each do |recording|
      RecordingCreator.new(recording:).call
      success 'Successfully migrated Recording:'
      info "RecordID: #{recording[:recordID]}"
    rescue StandardError => e
      err "Unable to migrate Recording:\nRecordID: #{recording[:recordID]}\nError: #{e}"
    end
  end
end
