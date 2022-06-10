# frozen_string_literal: true

require 'rails_helper'

describe MeetingStarter, type: :service do
  let(:room) { create(:room) }
  let(:url) { 'http://www.samplepdf.com/sample.pdf' }
  let(:service) { described_class.new(room:, logout_url: 'http://example.com', url:) }
  let(:options) do
    {
      logoutURL: 'http://example.com',
      'meta_bbb-origin-version': 3,
      'meta_bbb-origin': 'greenlight'
    }
  end

  describe '#call' do
    it 'calls BigBlueButtonApi with the right params' do
      expect_any_instance_of(BigBlueButtonApi)
        .to receive(:start_meeting)
        .with(room:, options:, url:)

      service.call
    end

    it 'merges the options with the computed options' do
      allow_any_instance_of(described_class)
        .to receive(:computed_options)
        .and_return({ test: 'test' })

      expect_any_instance_of(BigBlueButtonApi)
        .to receive(:start_meeting)
        .with(room:, options: { test: 'test' }, url:)

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
  end
end
