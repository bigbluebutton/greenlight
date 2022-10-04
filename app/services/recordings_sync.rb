# frozen_string_literal: true

class RecordingsSync
  def initialize(room:)
    @room = room
  end

  def call
    @room.recordings.destroy_all

    recordings = BigBlueButtonApi.new.get_recordings(meeting_ids: @room.meeting_id)
    recordings[:recordings].each do |recording|
      RecordingCreator.new(recording:).call
    end
  end
end
