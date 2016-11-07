class EndMeetingJob < ApplicationJob
  include BbbApi

  queue_as :default

  def perform(room)
    tries = 0
    sleep_time = 2

    while tries < 4
      bbb_res = bbb_get_meeting_info(room)

      if !bbb_res[:returncode]
        ActionCable.server.broadcast "#{room}_meeting_updates_channel",
          action: 'meeting_ended'
        break
      end

      sleep sleep_time
      sleep_time = sleep_time * 2
      tries += 1
    end

  end
end
