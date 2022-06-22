# frozen_string_literal: true

require 'rails_helper'
require 'bigbluebutton_api'

describe RecordingCreator, type: :service do
  let(:room) { create(:room) }

  describe '#call' do
    it 'creates single recording and format based on response' do
      room.update(meeting_id: 'random-1291479')

      described_class.new(recording: single_format_recording).call

      expect(room.recordings.first.record_id).to eq('f0e2be4518868febb0f381ebe7d46ae61364ef1e-1652287428125')
      expect(room.recordings.first.formats.count).to eq(1)
      expect(room.recordings.first.formats.first.recording_type).to eq('presentation')
    end

    it 'creates multiple formats based on response' do
      room.update(meeting_id: 'random-5678484')

      described_class.new(recording: multiple_formats_recording).call

      expect(room.recordings.first.formats.count).to eq(2)
      expect(room.recordings.first.formats.first.recording_type).to eq('presentation')
      expect(room.recordings.first.formats.second.recording_type).to eq('podcast')
    end

    it 'does not create duplicate recordings if called more than once' do
      room.update(meeting_id: 'random-1291479')

      described_class.new(recording: single_format_recording).call
      described_class.new(recording: single_format_recording).call
      described_class.new(recording: single_format_recording).call

      expect(room.recordings.count).to eq(1)
    end
  end

  private

  def single_format_recording
    {
      recordID: 'f0e2be4518868febb0f381ebe7d46ae61364ef1e-1652287428125',
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
      playback: {
        format: {
          type: 'presentation',
          url: 'https://test24.bigbluebutton.org/playback/presentation/2.3/f0e2be4518868febb0f381ebe7d46ae61364ef1e-1652287428125',
          processingTime: '6386',
          length: 0,
          size: '305475'
        }
      },
      data: {}
    }
  end

  def multiple_formats_recording
    {
      recordID: '955458f326d02d78ef8d27f4fbf5fafb7c2f666a-1652296432321',
      meetingID: 'random-5678484',
      internalMeetingID: '955458f326d02d78ef8d27f4fbf5fafb7c2f666a-1652296432321',
      name: 'random-5678484',
      isBreakout: 'false',
      published: true,
      state: 'published',
      startTime: 'Wed, 11 May 2022 15:13:52 -0400'.to_datetime,
      endTime: 'Wed, 11 May 2022 15:14:19 -0400'.to_datetime,
      participants: '1',
      rawSize: '960565',
      metadata: { isBreakout: 'false', meetingId: 'random-5678484', meetingName: 'random-5678484' },
      size: '272997',
      playback: {
        format: [{
          type: 'presentation',
          url: 'https://test24.bigbluebutton.org/playback/presentation/2.3/955458f326d02d78ef8d27f4fbf5fafb7c2f666a-1652296432321',
          processingTime: '5780',
          length: 0,
          size: '211880'
        },
                 {
                   type: 'podcast',
                   url: 'https://test24.bigbluebutton.org/podcast/955458f326d02d78ef8d27f4fbf5fafb7c2f666a-1652296432321/audio.ogg',
                   processingTime: '0',
                   length: 0,
                   size: '61117'
                 }]
      },
      data: {}
    }
  end
end
