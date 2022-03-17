# frozen_string_literal: true

require 'rails_helper'
require 'bigbluebutton_api'

describe BigBlueButtonApi, type: :service do
  let(:bbb_server) { described_class.new }
  let(:bbb_api) { bbb_server.bbb_server }

  describe 'Instance of BigBlueButtonApi being created' do
    it 'Created an instance of BigBlueButtonApi' do
      expect(bbb_api).to be_instance_of(BigBlueButton::BigBlueButtonApi)
    end

    it 'BigBlueButton client initialized once per request' do
      expect(bbb_server.bbb_server).to eq bbb_api
    end
  end
end
