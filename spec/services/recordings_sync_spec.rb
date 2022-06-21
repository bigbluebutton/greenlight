# frozen_string_literal: true

require 'rails_helper'

describe RecordingsSync, type: :service do
  let(:user) { create(:user) }
  let(:room) { create(:room, user:) }
  let(:service) { described_class.new(user:) }

  describe '#call' do
    it 'creates no new recordings and deletes all existing ones based on response' do
      create_list(:recording, 5, room:)

      allow_any_instance_of(BigBlueButtonApi).to receive(:get_recordings).and_return(no_recording_response)
      service.call
      expect(room.recordings.count).to eq(0)
    end

    it 'calls the RecordingCreator service with the right parameters' do
      room.update(meeting_id: 'random-1291479')
      allow_any_instance_of(BigBlueButtonApi).to receive(:get_recordings).and_return(multiple_recordings_response)
      allow_any_instance_of(RecordingCreator).to receive(:call).and_return(nil)

      expect(RecordingCreator).to receive(:new).with(recording: multiple_recordings_response[:recordings][0]).and_call_original
      expect(RecordingCreator).to receive(:new).with(recording: multiple_recordings_response[:recordings][1]).and_call_original

      service.call
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
