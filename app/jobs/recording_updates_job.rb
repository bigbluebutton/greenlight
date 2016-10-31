class RecordingUpdatesJob < ApplicationJob
  include BbbApi

  queue_as :default

  def perform(room, record_id, published)
    tries = 0
    sleep_time = 2

    while tries < 4
      bbb_res = bbb_get_recordings(nil, record_id)
      if bbb_res[:recordings].first[:published].to_s == published
        ActionCable.server.broadcast "#{room}_recording_updates_channel",
          published: bbb_res[:recordings].first[:published]
        break
      end
      sleep sleep_time
      sleep_time = sleep_time * 2
      tries += 1
    end
  end
end
