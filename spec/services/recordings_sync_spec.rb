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

describe RecordingsSync, type: :service do
  let(:user) { create(:user) }
  let(:room) { create(:room, user:, recordings_processing: 5) }
  let(:service) { described_class.new(room:, provider: 'greenlight') }

  before do
    allow_any_instance_of(BigBlueButtonApi).to receive(:delete_recordings).and_return(true)
  end

  describe '#call' do
    let(:fake_recording_creator) { instance_double(RecordingCreator) }
    let(:other_recordings) { create_list(:recording, 2) }

    before do
      create_list(:recording, 2, room:)

      allow(RecordingCreator).to receive(:new).and_return(fake_recording_creator)
      allow(fake_recording_creator).to receive(:call).and_return(true)
    end

    context 'when BBB returns no recordings' do
      before do
        allow_any_instance_of(BigBlueButtonApi).to receive(:get_recordings).and_return(no_recording_response)
      end

      it 'does not call RecordingsCreator service' do
        expect_any_instance_of(BigBlueButtonApi).to receive(:get_recordings).with(meeting_ids: room.meeting_id)
        expect(RecordingCreator).not_to receive(:new)

        service.call
        expect(room.recordings.count).to be_zero
        expect(Recording.where(id: other_recordings.pluck(:id))).to eq(other_recordings)
      end
    end

    context 'when BBB returns recordings' do
      before do
        room.update(meeting_id: 'random-1291479')
        allow_any_instance_of(BigBlueButtonApi).to receive(:get_recordings).and_return(multiple_recordings_response)
      end

      it 'calls the RecordingCreator service with the right parameters' do
        expect_any_instance_of(BigBlueButtonApi).to receive(:get_recordings).with(meeting_ids: room.meeting_id)
        expect(RecordingCreator).to receive(:new).with(recording: multiple_recordings_response[:recordings][0]).and_call_original
        expect(RecordingCreator).to receive(:new).with(recording: multiple_recordings_response[:recordings][1]).and_call_original

        service.call
        expect(Recording.where(id: other_recordings.pluck(:id))).to eq(other_recordings)
      end

      it 'resets the recordings processing value for the room' do
        expect { service.call }.to change(room, :recordings_processing).from(5).to(0)
      end
    end
  end

  private

  def no_recording_response
    { returncode: true,
      recordings: [],
      messageKey: '',
      message: '' }
  end

  def multiple_recordings_response
    { returncode: true,
      recordings: [{ recordID: 'f0e2be4518868febb0f381ebe7d46ae61364ef1e-1652287428125',
                     meetingID: 'random-1291479',
                     internalMeetingID: 'f0e2be4518868febb0f381ebe7d46ae61364ef1e-1652287428125',
                     name: 'random-1291479',
                     isBreakout: 'false',
                     published: true,
                     state: 'published',
                     startTime: 'Wed, 11 May 2022 12:43:48 -0400'.to_datetime,
                     endTime: 'Wed, 11 May 2022 12:44:20 -0400'.to_datetime,
                     participants: '1',
                     rawSize: '977816',
                     metadata: { isBreakout: 'false', meetingId: 'random-1291479', meetingName: 'random-1291479' },
                     size: '305475',
                     playback: { format: { type: 'presentation',
                                           url: 'https://test24.bigbluebutton.org/playback/presentation/2.3/f0e2be4518868febb0f381ebe7d46ae61364ef1e-1652287428125',
                                           processingTime: '6386',
                                           length: 0,
                                           size: '305475' } },
                     data: {} },
                   { recordID: 'f0e2be4518868febb0f381ebe7d46ae61364ef1e-1652287428125',
                     meetingID: 'random-1291479',
                     internalMeetingID: 'f0e2be4518868febb0f381ebe7d46ae61364ef1e-1652287428125',
                     name: 'random-1291479',
                     isBreakout: 'false',
                     published: true,
                     state: 'published',
                     startTime: 'Wed, 11 May 2022 12:43:48 -0400'.to_datetime,
                     endTime: 'Wed, 11 May 2022 12:44:20 -0400'.to_datetime,
                     participants: '1',
                     rawSize: '977816',
                     metadata: { isBreakout: 'false', meetingId: 'random-1291479', meetingName: 'random-1291479' },
                     size: '305475',
                     playback: { format: { type: 'presentation',
                                           url: 'https://test24.bigbluebutton.org/playback/presentation/2.3/f0e2be4518868febb0f381ebe7d46ae61364ef1e-1652287428125',
                                           processingTime: '6386',
                                           length: 0,
                                           size: '305475' } },
                     data: {} }],
      messageKey: '',
      message: '' }
  end
end
