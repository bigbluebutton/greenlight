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

namespace :poller do
  # Does a check if a meeting set as online is still online
  task :meeting_poller, %i[provider] => :environment do |_task, args|
    args.with_defaults(provider: 'greenlight')

    online_meetings = Room.with_provider(args[:provider])
                          .where(online: true)

    RunningMeetingChecker(rooms: online_meetings, provider: args[:provider]).call

  rescue StandardError => e
    err "Unable to poll meeting:\nMeetingID: #{room.meeting_id}\nError: #{e}"
  end

  # Does a check if a recording from a recent meeting has not been created in GL
  task :recordings_poller, %i[provider] => :environment do |_task, args|
    args.with_defaults(provider: 'greenlight')

    recent_meetings = Room.with_provider(args[:provider])
                          .where(last_session: 1.hour.ago..Time.zone.now)
                          .where(online: false)

    recent_meetings.each do |meeting|
      recordings = BigBlueButtonApi.new(provider: current_provider).get_recordings(meeting_ids: meeting.meeting_id)
      recordings[:recordings].each do |recording|

        # TODO: - samuel: duplication in external_controller, this block belongs in RecordingCreator
        unless Recording.exists?(record_id: recording[:recordID])
          room = Room.find_by(meeting_id: recording[:meetingID])
          room.update(recordings_processing: room.recordings_processing - 1) unless room.recordings_processing.zero?
        end

        # Need to call service even if Recording already exists in case the recording visibility was updated
        RecordingCreator.new(recording:).call

      rescue StandardError => e
        err "Unable to create Recording:\nRecordID: #{recording[:recordID]}\nError: #{e}"
        next
      end
    end
  end

  task :run_all, %i[duration] => :environment do |_task, args|
    args.with_defaults(duration: 3600)

    loop do
      Rake::Task['poller:meeting_poller'].invoke

      # Pool recordings only if the provider has record enabled
      if RoomsConfiguration.joins(:meeting_option).find_by(provider: current_provider, 'meeting_option.name': 'record').value
        Rake::Task['poller:recordings_poller'].invoke
      end

    rescue StandardError => e
      err "An error occurred: #{e.message}. Continuing..."
    ensure
      sleep args[:duration].to_i
    end
  end
end

