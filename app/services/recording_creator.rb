# frozen_string_literal: true

class RecordingCreator
  def initialize(recording:)
    @recording = recording
  end

  def call
    room_id = Room.find_by(meeting_id: @recording[:meetingID]).id
    visibility = get_recording_visibility(recording: @recording)

    # Get length of presentation format(s)
    length = get_recording_length(recording: @recording)

    new_name = @recording[:metadata][:name] || @recording[:name]

    new_recording = Recording.find_or_create_by(room_id:, name: new_name, record_id: @recording[:recordID], visibility:,
                                                participants: @recording[:participants], length:, protectable: @recording[:protected].present?)

    # Create format(s)
    create_formats(recording: @recording, new_recording:)
  end

  private

  # Returns the visibility of the recording (published, unpublished or protected)
  def get_recording_visibility(recording:)
    return 'Protected' if recording[:protected] == 'true'

    return 'Published' if recording[:published] == 'true'

    'Unpublished'
  end

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
        Format.find_or_create_by(recording_id: new_recording.id, recording_type: format[:type], url: format[:url])
      end
    else
      Format.find_or_create_by(recording_id: new_recording.id, recording_type: recording[:playback][:format][:type],
                               url: recording[:playback][:format][:url])
    end
  end
end
