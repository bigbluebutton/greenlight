# frozen_string_literal: true

class MeetingStarter
  include Rails.application.routes.url_helpers

  def initialize(room:, base_url:, current_user:)
    @room = room
    @current_user = current_user
    @base_url = base_url
  end

  def call
    # TODO: amir - Check the legitimately of the action.
    options = RoomSettingsGetter.new(room_id: @room.id, provider: @room.user.provider, current_user: @current_user, only_bbb_options: true).call
    viewer_code = RoomSettingsGetter.new(
      room_id: @room.id,
      provider: @room.user.provider,
      current_user: @current_user,
      show_codes: true,
      settings: 'glViewerAccessCode'
    ).call

    options.merge!(computed_options(access_code: viewer_code['glViewerAccessCode']))

    retries = 0
    begin
      meeting = BigBlueButtonApi.new.start_meeting(room: @room, options:, presentation_url:)

      @room.update!(online: true, last_session: DateTime.strptime(meeting[:createTime].to_s, '%Q'))

      ActionCable.server.broadcast "#{@room.friendly_id}_rooms_channel", 'started'
    rescue BigBlueButton::BigBlueButtonException => e
      retries += 1
      retry if retries < 3 && e.key != 'idNotUnique'
      raise e
    end
  end

  private

  def computed_options(access_code:)
    room_url = File.join(@base_url, '/rooms/', @room.friendly_id, '/join')
    moderator_message = "#{I18n.t('meeting.moderator_message')}<br>#{room_url}"
    moderator_message += "<br>#{I18n.t('meeting.access_code', code: access_code)}" if access_code.present?
    {
      moderatorOnlyMessage: moderator_message,
      logoutURL: room_url,
      meta_endCallbackUrl: meeting_ended_url(host: @base_url),
      'meta_bbb-recording-ready-url': recording_ready_url(host: @base_url),
      'meta_bbb-origin-version': 3,
      'meta_bbb-origin': 'greenlight'
    }
  end

  def presentation_url
    return unless @room.presentation.attached?

    rails_blob_url(@room.presentation, host: @base_url).gsub('&', '%26')
  end
end
