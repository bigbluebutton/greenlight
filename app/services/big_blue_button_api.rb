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

  # Start a session for a specific room and returns the join URL.
  def start_session(room:, session_starter:, options: {})
    # TODO: amir - Revisit this.
    create_options = default_create_opts.merge(options)
    join_options = default_join_opts.merge(create_options) # TODO: amir - Revisit this (createTime,...).

    meeting_id = room.friendly_id
    user_name = session_starter&.name || 'Someone'
    password = (session_starter && create_options[:moderatorPW]) || create_options[:attendeePW]

    create_session meeting_name: room.name, meeting_id:, options: create_options
    get_session_join_url meeting_id:, user_name:, password:, options: join_options
  end

  private

  def create_session(meeting_name:, meeting_id:, options: {}, modules: nil)
    bbb_server.create_meeting meeting_name, meeting_id, options, modules
  end

  def get_session_join_url(meeting_id:, user_name:, password:, options: {})
    bbb_server.join_meeting_url meeting_id, user_name, password, options
  end

  def bbb_endpoint
    ENV['BIGBLUEBUTTON_ENDPOINT'] || 'https://test-install.blindsidenetworks.com/bigbluebutton/api/'
  end

  def bbb_secret
    ENV['BIGBLUEBUTTON_SECRET'] || '8cd8ef52e8e101574e400365b55e11a6'
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

  def default_join_opts
    {
      join_via_html5: true
    }
  end
end
