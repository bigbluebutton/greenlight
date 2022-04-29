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
    # TODO: amir - Revisit this.
    room_meeting_option_name_values_hash = room.room_meeting_options.includes(:meeting_option).where.not('name LIKE ?', 'gl%').pluck(:name,
                                                                                                                                     :value).to_h
    create_options = room_meeting_option_name_values_hash.merge(options)
    join_options = { join_via_html5: true } # TODO: amir - Revisit this (createTime,...).

    user_name = meeting_starter&.name || 'Someone'
    password = (meeting_starter && create_options['moderatorPW']) || create_options['attendeePW']

    bbb_server.create_meeting room.name, room.friendly_id, create_options
    bbb_server.join_meeting_url room.friendly_id, user_name, password, join_options
  end

  private

  def bbb_endpoint
    ENV.fetch 'BIGBLUEBUTTON_ENDPOINT', 'https://test-install.blindsidenetworks.com/bigbluebutton/api'
  end

  def bbb_secret
    ENV.fetch 'BIGBLUEBUTTON_SECRET', '8cd8ef52e8e101574e400365b55e11a6'
  end
end
