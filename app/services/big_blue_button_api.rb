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
  def start_meeting(room:, options: {}, presentation_url: nil)
    if presentation_url.present?
      modules = BigBlueButton::BigBlueButtonModules.new
      modules.add_presentation(:url, presentation_url)
      bbb_server.create_meeting(room.name, room.meeting_id, options, modules)
    else
      bbb_server.create_meeting(room.name, room.meeting_id, options)
    end
  end

  def join_meeting(room:, name:, role:)
    url = bbb_server.join_meeting_url(
      room.meeting_id,
      name,
      '', # empty password -> use the role passed ing
      {
        role:,
        createTime: room.last_session&.to_datetime&.strftime('%Q')
      }.compact
    )

    Rails.logger.debug url

    url
  end

  def meeting_running?(room:)
    bbb_server.is_meeting_running?(room.meeting_id)
  end

  def active_meetings
    bbb_server.get_meetings[:meetings]
  end

  # Retrieve the recordings that belong to room with given record_id
  def get_recording(record_id:)
    bbb_server.get_recordings(recordID: record_id)[:recordings][0]
  end

  # Retrieve the recordings that belong to room with given meeting_id
  def get_recordings(meeting_ids:)
    bbb_server.get_recordings(meetingID: meeting_ids)
  end

  # Delete the recording(s) with given record_ids
  def delete_recordings(record_ids:)
    bbb_server.delete_recordings(record_ids)
  end

  # Sets publish (true/false) for recording(s) with given record_id(s)
  def publish_recordings(record_ids:, publish:)
    bbb_server.publish_recordings(record_ids, publish)
  end

  def update_recordings(record_id:, meta_hash:)
    bbb_server.update_recordings(record_id, {}, meta_hash)
  end

  # Decodes the JWT using the BBB secret as key (Used in Recording Ready Callback)
  def decode_jwt(token)
    JWT.decode token, bbb_secret, true, { algorithm: 'HS256' }
  end

  private

  def bbb_endpoint
    ENV.fetch 'BIGBLUEBUTTON_ENDPOINT', 'https://test-install.blindsidenetworks.com/bigbluebutton/api'
  end

  def bbb_secret
    ENV.fetch 'BIGBLUEBUTTON_SECRET', '8cd8ef52e8e101574e400365b55e11a6'
  end
end
