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
      room_id = Room.find_by(meeting_id: recording[:meetingID]).id

      # Get length of presentation format(s)
      length = get_recording_length(recording:)

      new_recording = Recording.create(room_id:, name: recording[:name], record_id: recording[:recordID], visibility: 'Unlisted',
                                       users: recording[:participants], length:)

      # Create format(s)
      create_formats(recording:, new_recording:)
    end
  end

  private

  # Returns the length of presentation recording for the recording given
  def get_recording_length(recording:)
    length = 0
    if recording[:playback][:format].is_a?(Array)
      recording[:playback][:format].each do |formats|
        length = formats[:length] if formats[:type] == 'presentation'
      end
    else
      length = recording[:playback][:format][:length]
    end
    length
  end

  # Creates format(s) for given new_recording
  def create_formats(recording:, new_recording:)
    if recording[:playback][:format].is_a?(Array)
      recording[:playback][:format].each do |format|
        Format.create(recording_id: new_recording.id, recording_type: format[:type], url: format[:url])
      end
    else
      Format.create(recording_id: new_recording.id, recording_type: recording[:playback][:format][:type], url: recording[:playback][:format][:url])
    end
  end
end
