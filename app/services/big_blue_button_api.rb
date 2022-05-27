# frozen_string_literal: true

require 'bigbluebutton_api'

class BigBlueButtonApi
  def initialize; end

  # Sets a BigBlueButtonApi object for interacting with the API.
  def bbb_server
    # TODO: Amir - Protect the BBB secret.
    # TODO: Hadi - Add additional logic here...
    @bbb_server ||= BigBlueButton::BigBlueButtonApi.new(bbb_endpoint, bbb_secret, '1.8')
  end

  # Start a meeting for a specific room and returns the join URL.
  def start_meeting(room:, options: {})
    bbb_server.create_meeting room.name, room.meeting_id, options
  end

  def join_meeting(room:, name:, role:)
    bbb_server.join_meeting_url room.meeting_id, name, '', { role: }
  end

  def meeting_running?(room:)
    bbb_server.is_meeting_running?(room.meeting_id)
  end

  # Retrieve the recordings that belong to room with given meeting_id
  def get_recordings(meeting_ids:)
    bbb_server.get_recordings(meetingID: meeting_ids)
  end

  # Delete the recording(s) with given record_ids
  def delete_recordings(record_ids:)
    bbb_server.delete_recordings(record_ids)
  end

  private

  def bbb_endpoint
    ENV.fetch 'BIGBLUEBUTTON_ENDPOINT', 'https://test-install.blindsidenetworks.com/bigbluebutton/api'
  end

  def bbb_secret
    ENV.fetch 'BIGBLUEBUTTON_SECRET', '8cd8ef52e8e101574e400365b55e11a6'
  end
end
