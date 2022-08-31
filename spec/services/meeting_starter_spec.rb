# frozen_string_literal: true

require 'rails_helper'
require 'bigbluebutton_api'

describe MeetingStarter, type: :service do
  let(:user) { create(:user) }
  let(:room) { create(:room) }
  let(:presentation_url) { 'http://www.samplepdf.com/sample.pdf' }
  let(:service) do
    described_class.new(
      room:,
      logout_url: 'http://example.com',
      presentation_url:,
      meeting_ended: 'http://example.com/meeting_ended',
      recording_ready: 'http://example.com/recording_ready',
      provider: 'greenlight',
      current_user: user
    )
  end
  let(:options) do
    {
      logoutURL: 'http://example.com',
      meta_endCallbackUrl: 'http://example.com/meeting_ended',
      'meta_bbb-recording-ready-url': 'http://example.com/recording_ready',
      'meta_bbb-origin-version': 3,
      'meta_bbb-origin': 'greenlight',
      setting: 'value'
    }
  end

  describe '#call' do
    let(:room_setting_getter_service) { instance_double(RoomSettingsGetter) }

    before do
      allow(RoomSettingsGetter).to receive(:new).and_return(room_setting_getter_service)
      allow(room_setting_getter_service).to receive(:call).and_return({ setting: 'value' })
    end

    it 'calls BigBlueButtonApi and RoomSettingsGetter with the right params' do
      allow_any_instance_of(BigBlueButtonApi)
        .to receive(:start_meeting)
        .and_return(meeting_starter_response)

      expect(RoomSettingsGetter)
        .to receive(:new)
        .with(room_id: room.id, provider: 'greenlight', current_user: user, only_bbb_options: true)

      expect(room_setting_getter_service)
        .to receive(:call)

      expect_any_instance_of(BigBlueButtonApi)
        .to receive(:start_meeting)
        .with(room:, options:, presentation_url:)

      service.call
    end

    it 'merges the options with the computed options' do
      allow_any_instance_of(described_class)
        .to receive(:computed_options)
        .and_return({ test: 'test' })

      allow_any_instance_of(BigBlueButtonApi)
        .to receive(:start_meeting)
        .and_return(meeting_starter_response)

      expect_any_instance_of(BigBlueButtonApi)
        .to receive(:start_meeting)
        .with(room:, options: { setting: 'value', test: 'test' }, presentation_url:)

      service.call
    end

    it 'broadcasts to ActionCable that the meeting has started' do
      allow_any_instance_of(BigBlueButtonApi)
        .to receive(:start_meeting)
        .and_return(meeting_starter_response)

      expect(ActionCable.server)
        .to receive(:broadcast)
        .with("#{room.friendly_id}_rooms_channel", 'started')

      service.call
    end

    it 'updates the last session date when a meeting is started' do
      allow_any_instance_of(BigBlueButtonApi)
        .to receive(:start_meeting)
        .with(room:, options:, presentation_url:)
        .and_return(meeting_starter_response)

      service.call

      expect(room.last_session).to eql(DateTime.strptime(meeting_starter_response[:createTime].to_s, '%Q').utc)
    end

    context 'retry' do
      it 'retries 3 times if the call fails' do
        allow(BigBlueButtonApi)
          .to receive(:new)
                .and_raise(BigBlueButton::BigBlueButtonException)

        expect(BigBlueButtonApi)
          .to receive(:new)
                .exactly(3).times

        expect { service.call }.to raise_error(BigBlueButton::BigBlueButtonException)
      end

      it 'doesnt retry if the messageKey is idNotUnique' do
        exception = BigBlueButton::BigBlueButtonException.new('idNotUnique')
        exception.key = 'idNotUnique'

        allow(BigBlueButtonApi)
          .to receive(:new)
                .and_raise(exception)

        expect(BigBlueButtonApi)
          .to receive(:new)
                .once

        expect { service.call }.to raise_error(BigBlueButton::BigBlueButtonException)
      end
    end
  end

  private

  def meeting_starter_response
    {
      returncode: true,
      meetingID: 'hulsdzwvitlk1dbekzxdprshsxmvycvar0jeaszc',
      attendeePW: '12345',
      moderatorPW: '54321',
      createTime: 1_389_464_535_956,
      hasBeenForciblyEnded: false,
      messageKey: '',
      message: ''
    }
  end
end
