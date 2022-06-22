# frozen_string_literal: true

class RecordingsSync
  def initialize(params)
    @user = params[:user]
  end

  def call
    rooms = @user.rooms

    # Get the meeting_id of all the current user's rooms
    meeting_ids = rooms.map(&:meeting_id)

    Recording.destroy_by(room_id: rooms.map(&:id))

    recordings = BigBlueButtonApi.new.get_recordings(meeting_ids:)
    recordings[:recordings].each do |recording|
      RecordingCreator.new(recording:).call
    end
  end
end
