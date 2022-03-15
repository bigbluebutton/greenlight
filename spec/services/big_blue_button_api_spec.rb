# frozen_string_literal: true

require 'rails_helper'
require 'bigbluebutton_api'

describe BigBlueButtonApi, type: :service do
  let(:bbb_server) { described_class.new }

  describe 'Instance of BigBlueButtonApi created' do
    it 'bbb_server is created and an instance of BigBlueBUttonApi' do
      expect(bbb_server).to be_instance_of(described_class)
    end
  end
end
