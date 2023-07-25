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
  desc 'Runs all pollers'
  task :run_all, %i[interval] => :environment do |_task, args|
    args.with_defaults(interval: 30)
    interval = args[:interval].to_i.minutes # set the interval in minutes

    poller_tasks = %w[poller:meetings_poller poller:recordings_poller]

    info "Running poller with interval #{interval}"
    loop do
      poller_tasks.each do |poller_task|
        info "Running #{poller_task} at #{Time.zone.now}"
        Rake::Task[poller_task].invoke(interval)
      rescue StandardError => e
        err "An error occurred in #{poller_task}: #{e.message}. Continuing..."
      end

      sleep interval

      poller_tasks.each do |poller_task|
        Rake::Task[poller_task].reenable
      end
    end
  end

  desc 'Polls meetings to check if they are still online'
  task meetings_poller: :environment do
    online_meetings = Room.includes(:user).where(online: true)

    RunningMeetingChecker.new(rooms: online_meetings).call

  rescue StandardError => e
    err "Unable to poll meetings. Error: #{e}"
  end

  desc 'Polls recordings to check if they have been created in GL'
  task :recordings_poller, %i[interval] => :environment do |_task, args|
    # Returns the providers which have recordings disabled
    disabled_recordings = RoomsConfiguration.joins(:meeting_option).where(meeting_option: { name: 'record' }, value: 'false').pluck(:provider)

    # Returns the rooms which have been online recently and have not been recorded yet
    recent_meeting_interval = args[:interval] * 2
    recent_meetings = Room.includes(:user)
                          .where(last_session: recent_meeting_interval.ago..Time.zone.now, online: false)
                          .where.not(user: { provider: disabled_recordings })

    recent_meetings.each do |meeting|
      recordings = BigBlueButtonApi.new(provider: meeting.user.provider).get_recordings(meeting_ids: meeting.meeting_id)
      recordings[:recordings].each do |recording|
        next if Recording.exists?(record_id: recording[:recordID])

        unless meeting.recordings_processing.zero?
          meeting.update(recordings_processing: meeting.recordings_processing - 1) # cond. in case both callbacks fail
        end

        RecordingCreator.new(recording:).call

      rescue StandardError => e
        err "Unable to poll Recording:\nRecordID: #{recording[:recordID]}\nError: #{e}"
        next
      end
    end
  end
end
