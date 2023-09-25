# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with Greenlight; if not, see <http://www.gnu.org/licenses/>.

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RunningMeetingChecker, type: :service do
  let!(:room) { create(:room, user: create(:user, provider: 'greenlight'), online: true) }
  let!(:rooms) { create_list(:room, 3, user: create(:user, provider: 'greenlight'), online: true) }

  describe '#call' do
    it 'retrieves the room participants for an online room' do
      allow_any_instance_of(BigBlueButtonApi).to receive(:get_meeting_info).with(meeting_id: room.meeting_id).and_return(meeting_info)

      described_class.new(rooms: room).call

      expect(room.participants).to eq(5)
    end

    it 'retrieves the room participants for multiple online room' do
      allow_any_instance_of(BigBlueButtonApi).to receive(:get_meeting_info).and_return(meeting_info)

      described_class.new(rooms:).call

      rooms.each do |room|
        expect(room.participants).to eq(5)
      end
    end

    it 'handles BigBlueButtonException and sets room online status to false' do
      allow_any_instance_of(BigBlueButtonApi).to receive(:get_meeting_info).and_raise(BigBlueButton::BigBlueButtonException)

      described_class.new(rooms: room).call

      expect(room.online).to be(false)
    end
  end

  def meeting_info
    {
      returncode: 'SUCCESS',
      meetingName: 'random-671854',
      meetingID: 'random-671854',
      internalMeetingID: 'ed055e2011ec6a76e39347808259a42a56f270d6-1690571458817',
      createTime: '1690571458817',
      createDate: 'Fri Jul 28 19:10:58 UTC 2023',
      voiceBridge: '79474',
      dialNumber: '343-633-0064',
      attendeePW: 'PvioX208',
      moderatorPW: 'b9WMdCtJ',
      running: 'false',
      duration: '0',
      hasUserJoined: 'false',
      recording: 'false',
      hasBeenForciblyEnded: 'false',
      startTime: '1690571458841',
      endTime: '0',
      participantCount: 5, # Also as integer
      listenerCount: '0',
      voiceParticipantCount: '0',
      videoCount: '0',
      maxUsers: '0',
      moderatorCount: '0',
      attendees: '',
      metadata: '',
      isBreakout: 'false'
    }
  end
end
