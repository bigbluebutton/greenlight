class RecordingDeletesJob < ApplicationJob
  include BbbApi

  queue_as :default

  def perform(room, record_id)
    tries = 0
    sleep_time = 2

    while tries < 4
      bbb_res = bbb_get_recordings(nil, record_id)
      if !bbb_res[:recordings] || bbb_res[:messageKey] == 'noRecordings'
        ActionCable.server.broadcast "#{room}_recording_updates_channel",
          action: 'delete',
          record_id: record_id
        break
      end
      sleep sleep_time
      sleep_time = sleep_time * 2
      tries += 1
    end
  end
end
