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
  let!(:online_room) { create(:room, online: true, user: create(:user, provider: 'greenlight')) }
  let(:bbb_api) { instance_double(BigBlueButtonApi) }

  before do
    allow(BigBlueButtonApi).to receive(:new).and_return(bbb_api)
  end

  context 'when the meeting is running' do
    let(:bbb_response) do
      {
        running: true
      }
    end

    it 'updates the online status to true' do
      allow(bbb_api).to receive(:get_meeting_info).and_return(bbb_response)

      described_class.new(rooms: Room.all).call

      expect(online_room.reload.online).to eq(bbb_response[:running])
    end
  end

  context 'when the meeting is not running' do
    it 'updates the online status to false' do
      allow(bbb_api).to receive(:get_meeting_info).and_raise(BigBlueButton::BigBlueButtonException)

      described_class.new(rooms: Room.all).call

      expect(online_room.reload.online).to be_falsey
    end
  end
end
