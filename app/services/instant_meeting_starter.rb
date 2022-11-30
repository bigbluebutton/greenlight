# frozen_string_literal: true

class InstantMeetingStarter
  include Rails.application.routes.url_helpers

  def initialize(room:, base_url:)
    @room = room
    @base_url = base_url
  end

  def call
    # TODO: amir - Check the legitimately of the action.
    retries = 0
    begin
      BigBlueButtonApi.new.start_meeting room: @room, options: computed_options

      ActionCable.server.broadcast "#{@room.friendly_id}_rooms_channel", 'started'
    rescue BigBlueButton::BigBlueButtonException => e
      retries += 1
      retry if retries < 3 && e.key != 'idNotUnique'
      raise e
    end
  end

  private

  # duplicated
  def computed_options
    room_url = File.join(@base_url, '/instant_rooms/', @room.friendly_id, '/join')
    {
      # TODO: - ahmad: Find a way to localize
      moderatorOnlyMessage: "To invite someone to the meeting, send them this link: #{room_url}",
      logoutURL: room_url,
      meta_endCallbackUrl: meeting_ended_url(host: @base_url),
      'meta_bbb-recording-ready-url': recording_ready_url(host: @base_url),
      'meta_bbb-origin-version': 3,
      'meta_bbb-origin': 'greenlight'
    }
  end
end
