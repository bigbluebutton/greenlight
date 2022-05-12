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

    before do
      allow(bbb_service).to receive(:default_create_opts).and_return(default_create_opts)
      allow(BigBlueButton::BigBlueButtonApi).to receive(:new).and_return(bbb_server)
      allow(bbb_server).to receive(:create_meeting).and_return(true)
      allow(bbb_server).to receive(:join_meeting_url).and_return(true)
    end

    it 'calls bbb_api#create_meeting' do
      expect(bbb_server).to receive(:create_meeting).with(room.name, room.friendly_id, default_create_opts)
      bbb_service.start_meeting room:, meeting_starter: nil, options: {}
    end

    describe 'calls bbb_api#join_meeting_url' do
      it 'With Moderator password and the meeting starter name for authenticated requests' do
        expect(bbb_server).to receive(:join_meeting_url).with(room.friendly_id, meeting_starter.name, default_create_opts[:moderatorPW],
                                                              default_join_opts)
        bbb_service.start_meeting room:, meeting_starter:, options: {}
      end

      it 'With attendee password and user name as "Someone" for unauthenticated requests' do
        expect(bbb_server).to receive(:join_meeting_url).with(room.friendly_id, 'Someone', default_create_opts[:attendeePW], default_join_opts)
        bbb_service.start_meeting room:, meeting_starter: nil, options: {}
      end
    end

    describe 'calls bbb#get_recordings' do
      it 'With list of meeting ids given as param' do
        expect(bbb_server).to receive(:get_recordings).with(meetingID: [1, 2, 3])
        bbb_service.get_recordings(meeting_ids: [1, 2, 3])
      end
    end
  end
end
