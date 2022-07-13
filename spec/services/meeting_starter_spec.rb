# frozen_string_literal: true

require 'rails_helper'

describe MeetingStarter, type: :service do
  let(:room) { create(:room) }
  let(:presentation_url) { 'http://www.samplepdf.com/sample.pdf' }
  let(:service) do
    described_class.new(
      room:,
      logout_url: 'http://example.com',
      presentation_url:,
      meeting_ended: 'http://example.com/meeting_ended',
      recording_ready: 'http://example.com/recording_ready'
    )
  end
  let(:options) do
    {
      logoutURL: 'http://example.com',
      meta_endCallbackUrl: 'http://example.com/meeting_ended',
      'meta_bbb-recording-ready-url': 'http://example.com/recording_ready',
      'meta_bbb-origin-version': 3,
      'meta_bbb-origin': 'greenlight'
    }
  end

  describe '#call' do
    it 'calls BigBlueButtonApi with the right params' do
      expect_any_instance_of(BigBlueButtonApi)
        .to receive(:start_meeting)
        .with(room:, options:, presentation_url:)

      service.call
    end

    it 'merges the options with the computed options' do
      allow_any_instance_of(described_class)
        .to receive(:computed_options)
        .and_return({ test: 'test' })

      expect_any_instance_of(BigBlueButtonApi)
        .to receive(:start_meeting)
        .with(room:, options: { test: 'test' }, presentation_url:)

      service.call
    end

    it 'retries 3 times if the call fails' do
      allow(BigBlueButtonApi)
        .to receive(:new)
        .and_raise(BigBlueButton::BigBlueButtonException)

      expect(BigBlueButtonApi)
        .to receive(:new)
        .exactly(3).times

      expect { service.call }.to raise_error(BigBlueButton::BigBlueButtonException)
    end

    it 'broadcasts to ActionCable that the meeting has started' do
      allow_any_instance_of(BigBlueButtonApi)
        .to receive(:start_meeting)
        .and_return(true)

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

      #returns nil even if explicitely told to return the meeting_starter_response
      #
      service.call

      expect(room.last_session).to change
    end
  end

  private

  def meeting_starter_response
    {
      returncode: true,
      meetingID: 'hulsdzwvitlk1dbekzxdprshsxmvycvar0jeaszc',
      attendeePW: '12345',
      moderatorPW: '54321',
      createTime: 1389464535956,
      hasBeenForciblyEnded: false,
      messageKey: '',
      message: ''
    }
  end
end
