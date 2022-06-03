# frozen_string_literal: true

require 'rails_helper'
require 'bigbluebutton_api'

describe BigBlueButtonApi, type: :service do
  let(:bbb_service) { described_class.new }

  before do
    ENV['BIGBLUEBUTTON_ENDPOINT'] = 'http://test.com/bigbluebutton/api'
    ENV['BIGBLUEBUTTON_SECRET'] = 'test'
  end

  describe 'Instance of BigBlueButtonApi being created' do
    it 'Created an instance of BigBlueButtonApi' do
      expect(BigBlueButton::BigBlueButtonApi).to receive(:new).with(ENV.fetch('BIGBLUEBUTTON_ENDPOINT', nil), ENV.fetch('BIGBLUEBUTTON_SECRET', nil),
                                                                    '1.8')
      bbb_service.bbb_server
    end

    it 'BigBlueButton client initialized once per request' do
      bbb_api = bbb_service.bbb_server
      bbb_api2 = bbb_service.bbb_server
      bbb_api3 = bbb_service.bbb_server

      expect(bbb_api).to eq(bbb_api2).and eq(bbb_api3)
    end
  end
end
