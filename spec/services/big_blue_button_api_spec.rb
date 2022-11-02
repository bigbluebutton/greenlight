# frozen_string_literal: true

require 'rails_helper'
require 'bigbluebutton_api'

describe BigBlueButtonApi, type: :service do
  let(:bbb_service) { described_class.new }

  before do
    Rails.configuration.bigbluebutton_endpoint = 'http://test.com/bigbluebutton/api'
    Rails.configuration.bigbluebutton_secret = 'test'
  end

  describe 'Instance of BigBlueButtonApi being created' do
    it 'Created an instance of BigBlueButtonApi' do
      expect(BigBlueButton::BigBlueButtonApi).to receive(:new).with(
        Rails.configuration.bigbluebutton_endpoint,
        Rails.configuration.bigbluebutton_secret,
        '1.8'
      )
      bbb_service.bbb_server
    end

    it 'BigBlueButton client initialized once per request' do
      bbb_api = bbb_service.bbb_server
      bbb_api2 = bbb_service.bbb_server
      bbb_api3 = bbb_service.bbb_server

      expect(bbb_api).to eq(bbb_api2).and eq(bbb_api3)
    end
  end

  describe '#update_recordings' do
    it 'calls bbb_api #update_recordings with the passed options' do
      allow_any_instance_of(BigBlueButton::BigBlueButtonApi).to receive(:update_recordings).and_return(true)
      expect_any_instance_of(BigBlueButton::BigBlueButtonApi).to receive(:update_recordings).with('recording_id', {},
                                                                                                  { 'meta_recording-name': 'recording_new_name' })
      bbb_service.update_recordings(record_id: 'recording_id', meta_hash: { 'meta_recording-name': 'recording_new_name' })
    end
  end
end
