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
  task :meetings_poller, %i[provider] => :environment do |_task, args|
    args.with_defaults(provider: 'greenlight')

    online_meetings = Room.joins(:user)
                          .where(users: { provider: args[:provider] }, online: true)

    RunningMeetingChecker.new(rooms: online_meetings, provider: args[:provider]).call

  rescue StandardError => e
    err "Unable to poll meetings. Error: #{e}"
  end

  # Does a check if a recording from a recent meeting has not been created in GL
  task :recordings_poller, %i[provider] => :environment do |_task, args|
    args.with_defaults(provider: 'greenlight')

    recent_meetings = Room.joins(:user)
                          .where(users: { provider: args[:provider] }, last_session: 1.hour.ago..Time.zone.now, online: false)

    # Fetch all rooms associated with the recent meetings in advance.
    recent_rooms = Room.where(meeting_id: recent_meetings.pluck(:meeting_id))
                       .index_by(&:meeting_id)

    recent_meetings.each do |meeting|
      recordings = BigBlueButtonApi.new(provider: args[:provider]).get_recordings(meeting_ids: meeting.meeting_id)
      recordings[:recordings].each do |recording|
        next if Recording.exists?(record_id: recording[:recordID])

        room = recent_rooms[recording[:meetingID]]
        room.update(recordings_processing: room.recordings_processing - 1) unless room.recordings_processing.zero? # cond. in case both callbacks fail

        RecordingCreator.new(recording:).call

      rescue StandardError => e
        err "Unable to poll Recording:\nRecordID: #{recording[:recordID]}\nError: #{e}"
        next
      end
    end
  end

  task :run_all, %i[provider interval] => :environment do |_task, args|
    args.with_defaults(provider: 'greenlight', interval: 3600)

    loop do
      begin
        Rake::Task['poller:meetings_poller'].execute
      rescue StandardError => e
        err "An error occurred in meetings poller: #{e.message}. Continuing..."
      end

      # Pool recordings only if the provider has record enabled
      record_enabled = RoomsConfiguration.joins(:meeting_option).find_by(provider: args[:provider], 'meeting_option.name': 'record').value
      if record_enabled
        begin
          Rake::Task['poller:recordings_poller'].execute
        rescue StandardError => e
          err "An error occurred in recordings poller: #{e.message}. Continuing..."
        end
      end

      sleep args[:interval].to_i
    end
  end
end
