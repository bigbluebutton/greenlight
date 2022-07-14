# frozen_string_literal: true

class MeetingStarter
  def initialize(room:, logout_url:, presentation_url:, meeting_ended:, recording_ready:)
    @room = room
    @logout_url = logout_url
    @presentation_url = presentation_url
    @meeting_ended = meeting_ended
    @recording_ready = recording_ready
  end

  def call
    # TODO: amir - Check the legitimately of the action.
    options = MeetingOption.bbb_options(room_id: @room.id).to_h

    options.merge!(computed_options)

    retries = 0
    begin
      meeting = BigBlueButtonApi.new.start_meeting room: @room, options: options, presentation_url: @presentation_url

      @room.update!(last_session: Time.zone.at(meeting[:createTime] / 1000))

      ActionCable.server.broadcast "#{@room.friendly_id}_rooms_channel", 'started'
    rescue BigBlueButton::BigBlueButtonException => e
      retries += 1
      retry unless retries >= 3
      raise e
    end
  end

  private

  def computed_options
    {
      logoutURL: @logout_url,
      meta_endCallbackUrl: @meeting_ended,
      'meta_bbb-recording-ready-url': @recording_ready,
      'meta_bbb-origin-version': 3,
      'meta_bbb-origin': 'greenlight'
    }
  end
end
