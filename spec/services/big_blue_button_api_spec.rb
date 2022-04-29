# frozen_string_literal: true

require 'rails_helper'
require 'bigbluebutton_api'

describe BigBlueButtonApi, type: :service do
  let(:bbb_service) { described_class.new }
  let(:default_create_opts) do
    {
      moderatorPW: 'mp',
      attendeePW: 'ap'
    }
  end

  let(:default_join_opts) do
    {
      join_via_html5: true
    }
  end

  before do
    ENV['BIGBLUEBUTTON_ENDPOINT'] = 'http://test.com/bigbluebutton/api'
    ENV['BIGBLUEBUTTON_SECRET'] = 'test'
  end

  describe 'Instance of BigBlueButtonApi being created' do
    it 'Created an instance of BigBlueButtonApi' do
      expect(BigBlueButton::BigBlueButtonApi).to receive(:new).with(ENV['BIGBLUEBUTTON_ENDPOINT'], ENV['BIGBLUEBUTTON_SECRET'],
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

  describe 'Room meeting creation' do
    let(:bbb_server) { instance_double(BigBlueButton::BigBlueButtonApi) }
    let(:room) { create(:room) }
    let(:meeting_starter) { room.user }
    let(:room_meeting_option_hash) do
      room.room_meeting_options.includes(:meeting_option).where.not('name LIKE ?', 'gl%').pluck(:name,
                                                                                                :value).to_h
    end

    before do
      allow(BigBlueButton::BigBlueButtonApi).to receive(:new).and_return(bbb_server)
      allow(bbb_server).to receive(:create_meeting).and_return(true)
      allow(bbb_server).to receive(:join_meeting_url).and_return(true)

      create :meeting_option, name: 'moderatorPW', default_value: 'moderatorPW'
      create :meeting_option, name: 'attendeePW', default_value: 'attendeePW'
      create :meeting_option, name: 'option', default_value: 'value'
      create :meeting_option, name: 'glOption', default_value: 'value'
    end

    it 'calls bbb_api#create_meeting' do
      expect(bbb_server).to receive(:create_meeting).with(room.name, room.friendly_id, room_meeting_option_hash)
      bbb_service.start_meeting room:, meeting_starter: nil, options: {}
    end

    describe 'calls bbb_api#join_meeting_url' do
      it 'With Moderator password and the meeting starter name for authenticated requests' do
        expect(bbb_server).to receive(:join_meeting_url).with(room.friendly_id, meeting_starter.name, room_meeting_option_hash['moderatorPW'],
                                                              default_join_opts)
        bbb_service.start_meeting room:, meeting_starter:, options: {}
      end

      it 'With attendee password and user name as "Someone" for unauthenticated requests' do
        expect(bbb_server).to receive(:join_meeting_url).with(room.friendly_id, 'Someone', room_meeting_option_hash['attendeePW'],
                                                              default_join_opts)
        bbb_service.start_meeting room:, meeting_starter: nil, options: {}
      end
    end
  end
end
