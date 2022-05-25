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
  def start_meeting(room:, meeting_starter:, options: {})
    create_options = default_create_opts.merge(options)
    join_options = { join_via_html5: true } # TODO: amir - Revisit this (createTime,...).

    user_name = meeting_starter&.name || 'Someone'
    password = (meeting_starter && create_options[:moderatorPW]) || create_options[:attendeePW]

    bbb_server.create_meeting room.name, room.friendly_id, create_options
    bbb_server.join_meeting_url room.friendly_id, user_name, password, join_options
  end

  def join_meeting(room:, name:)
    bbb_server.join_meeting_url room.friendly_id, name, '', { role: 'Viewer' }
  end

  def meeting_running?(room:)
    bbb_server.is_meeting_running?(room.friendly_id)
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

  def default_create_opts
    {
      # TODO: amir - revisit this.
      record: true,
      logoutURL: 'http://localhost',
      moderatorPW: 'mp',
      attendeePW: 'ap',
      moderatorOnlyMessage: 'Welcome Moderator',
      muteOnStart: false,
      guestPolicy: 'ALWAYS_ACCEPT',
      'meta_gl-v3-listed': 'public',
      'meta_bbb-origin-version': 3,
      'meta_bbb-origin': 'Greenlight'
    }
  end
end
