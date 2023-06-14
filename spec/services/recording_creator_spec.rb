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
require 'bigbluebutton_api'

describe RecordingCreator, type: :service do
  let(:room) { create(:room) }
  let(:bbb_recording) { single_format_recording }

  before { room.update(meeting_id: single_format_recording[:meetingID]) }

  describe '#call' do
    it 'creates recording if not found on GL based on BBB response' do
      expect do
        described_class.new(recording: bbb_recording).call
      end.to change(Recording, :count).from(0).to(1)

      expect(room.recordings.first.record_id).to eq(bbb_recording[:recordID])
      expect(room.recordings.first.participants).to eq(bbb_recording[:participants].to_i)
      expect(room.recordings.first.recorded_at.to_i).to eq(bbb_recording[:startTime].to_i)
    end

    it 'updates recording data if found on GL based on BBB response' do
      create(:recording, room:, record_id: bbb_recording[:recordID])

      expect do
        described_class.new(recording: bbb_recording).call
      end.not_to change(Recording, :count)

      expect(room.recordings.first.record_id).to eq(bbb_recording[:recordID])
      expect(room.recordings.first.participants).to eq(bbb_recording[:participants].to_i)
      expect(room.recordings.first.recorded_at.to_i).to eq(bbb_recording[:startTime].to_i)
    end

    it 'does not create duplicate recordings if called more than once' do
      expect do
        described_class.new(recording: bbb_recording).call
      end.to change(Recording, :count).from(0).to(1)

      expect do
        described_class.new(recording: bbb_recording).call
      end.not_to change(Recording, :count)

      expect do
        described_class.new(recording: bbb_recording).call
      end.not_to change(Recording, :count)
    end

    context 'Formats' do
      describe 'Single format' do
        let(:bbb_recording) { single_format_recording }

        it 'creates single recording and format based on response' do
          expect do
            described_class.new(recording: bbb_recording).call
          end.to change(Recording, :count).from(0).to(1)

          expect(room.recordings.first.formats.count).to eq(1)
          expect(room.recordings.first.formats.first.recording_type).to eq('presentation')
          expect(room.recordings.first.length).to eq(bbb_recording[:playback][:format][:length])
        end
      end

      describe 'Multiple formats' do
        let(:bbb_recording) { multiple_formats_recording }

        it 'creates multiple formats based on response' do
          expect do
            described_class.new(recording: bbb_recording).call
          end.to change(Recording, :count).from(0).to(1)

          expect(room.recordings.first.formats.count).to eq(2)
          expect(room.recordings.first.formats.first.recording_type).to eq('presentation')
          expect(room.recordings.first.formats.second.recording_type).to eq('podcast')
          expect(room.recordings.first.length).to eq(bbb_recording[:playback][:format][0][:length])
        end
      end
    end

    context 'Meeting ID' do
      describe 'When meta Meeting ID is NOT returned' do
        let(:bbb_recording) { without_meta_meeting_id_recording(meeting_id: room.meeting_id) }

        it 'Finds recording room by the response meeting ID' do
          expect do
            described_class.new(recording: bbb_recording).call
          end.not_to raise_error

          expect(room.recordings.first.record_id).to eq(bbb_recording[:recordID])
          expect(room.meeting_id).to eq(bbb_recording[:meetingID])
          expect(room.meeting_id).not_to eq(bbb_recording[:metadata][:meetingId])
        end
      end

      describe 'When meta Meeting ID is returned' do
        let(:bbb_recording) { with_meta_meeting_id_recording(meeting_id: room.meeting_id) }

        it 'Finds recording room by the response metadata meeting ID' do
          expect do
            described_class.new(recording: bbb_recording).call
          end.not_to raise_error

          expect(room.recordings.first.record_id).to eq(bbb_recording[:recordID])
          expect(room.meeting_id).to eq(bbb_recording[:metadata][:meetingId])
          expect(room.meeting_id).not_to eq(bbb_recording[:meetingID])
        end
      end

      describe 'Inexsitent room for the given meeting ID' do
        let(:bbb_recording) { without_meta_meeting_id_recording(meeting_id: '404') }

        it 'Fails without upserting recording' do
          expect do
            described_class.new(recording: bbb_recording).call
          end.to raise_error(ActiveRecord::RecordNotFound)

          expect(room.recordings.count).to eq(0)
        end
      end
    end

    context 'Name' do
      describe 'When meta name is NOT returned' do
        let(:bbb_recording) { without_meta_name_recording }

        it 'sets recording name to response name' do
          described_class.new(recording: bbb_recording).call

          expect(room.recordings.first.name).not_to eq(bbb_recording[:metadata][:name])
          expect(room.recordings.first.name).to eq(bbb_recording[:name])
        end
      end

      describe 'When meta name is returned' do
        let(:bbb_recording) { with_meta_name_recording }

        it 'sets recording name to response metadata name' do
          described_class.new(recording: bbb_recording).call

          expect(room.recordings.first.name).not_to eq(bbb_recording[:name])
          expect(room.recordings.first.name).to eq(bbb_recording[:metadata][:name])
        end
      end
    end

    context 'Protectable' do
      describe 'When BBB server protected feature is enabled' do
        let(:bbb_recording) { protected_recording }

        it 'returns recording protectable attribute as true' do
          described_class.new(recording: bbb_recording).call
          expect(room.recordings.first.protectable).to be(true)
        end
      end

      describe 'When BBB server protected feature is NOT enabled' do
        let(:bbb_recording) { single_format_recording }

        it 'returns recording protectable attribute as false if the bbb server protected feature is not enabled' do
          described_class.new(recording: bbb_recording).call
          expect(room.recordings.first.protectable).to be(false)
        end
      end
    end

    context 'Visibility' do
      describe 'Published' do
        let(:bbb_recording) { published_recording }

        it 'sets a BBB published recording visibility to "Published"' do
          described_class.new(recording: bbb_recording).call

          expect(room.recordings.first.visibility).to eq(Recording::VISIBILITIES[:published])
        end
      end

      describe 'Protected' do
        let(:bbb_recording) { protected_recording }

        it 'sets a BBB published recording visibility to "Protected"' do
          described_class.new(recording: bbb_recording).call

          expect(room.recordings.first.visibility).to eq(Recording::VISIBILITIES[:protected])
        end
      end

      describe 'Unpublished' do
        let(:bbb_recording) { unpublished_recording }

        it 'sets a BBB published recording visibility to "Unpublished"' do
          described_class.new(recording: bbb_recording).call

          expect(room.recordings.first.visibility).to eq(Recording::VISIBILITIES[:unpublished])
        end
      end

      describe 'Public' do
        let(:bbb_recording) { public_recording }

        it 'sets a BBB public recording visibility to "Public"' do
          described_class.new(recording: bbb_recording).call

          expect(room.recordings.first.visibility).to eq(Recording::VISIBILITIES[:public])
        end
      end

      describe 'Public/Protected' do
        let(:bbb_recording) { public_protected_recording }

        it 'sets a BBB Public/Protected recording visibility to "Public/Protected"' do
          described_class.new(recording: bbb_recording).call

          expect(room.recordings.first.visibility).to eq(Recording::VISIBILITIES[:public_protected])
        end
      end

      describe 'Unkown cases' do
        let(:bbb_recording) { unkown_visibility_recording }

        it 'sets a BBB with unkown recording visibility to "Unpublished"' do
          described_class.new(recording: bbb_recording).call

          expect(room.recordings.first.visibility).to eq(Recording::VISIBILITIES[:unpublished])
        end
      end
    end
  end

  private

  def dummy_recording(**args)
    {
      recordID: 'f0e2be4518868febb0f381ebe7d46ae61364ef1e-1652287428125',
      meetingID: 'random-1291479',
      internalMeetingID: 'f0e2be4518868febb0f381ebe7d46ae61364ef1e-1652287428125',
      name: 'random-1291479',
      isBreakout: 'false',
      published: true,
      state: 'published',
      startTime: Faker::Time.between(from: 2.days.ago, to: Time.zone.now).to_datetime,
      endTime: Faker::Time.between(from: 2.days.ago, to: Time.zone.now).to_datetime,
      participants: Faker::Number.within(range: 1..100).to_s,
      rawSize: '977816',
      metadata: { isBreakout: 'false' },
      size: '305475',
      playback: {
        format: {
          type: 'presentation',
          url: 'https://test24.bigbluebutton.org/playback/presentation/2.3/f0e2be4518868febb0f381ebe7d46ae61364ef1e-1652287428125',
          processingTime: '6386',
          length: Faker::Number.within(range: 1..60),
          size: '305475'
        }
      },
      data: {}
    }.merge(args)
  end

  def single_format_recording
    dummy_recording
  end

  def multiple_formats_recording
    dummy_recording playback: {
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
    }
  end

  def without_meta_meeting_id_recording(meeting_id:)
    dummy_recording meetingID: meeting_id
  end

  def with_meta_meeting_id_recording(meeting_id:)
    dummy_recording meetingID: "NOT_#{meeting_id}", metadata: { isBreakout: 'false', meetingId: meeting_id }
  end

  def without_meta_name_recording
    name = Faker::Name.name

    dummy_recording name:, metadata: { isBreakout: 'false' }
  end

  def with_meta_name_recording
    name = Faker::Name.name

    dummy_recording name: "WRONG_#{name}", metadata: { isBreakout: 'false', name: }
  end

  def protected_recording
    dummy_recording published: true, protected: true, metadata: { isBreakout: 'false', 'gl-listed': [false, nil].sample }
  end

  def published_recording
    dummy_recording published: true, protected: false, metadata: { isBreakout: 'false', 'gl-listed': [false, nil].sample }
  end

  def unpublished_recording
    dummy_recording published: false, protected: false, metadata: { isBreakout: 'false', 'gl-listed': [false, nil].sample }
  end

  def public_recording
    dummy_recording published: true, protected: false, metadata: { isBreakout: 'false', 'gl-listed': true }
  end

  def public_protected_recording
    dummy_recording published: true, protected: true, metadata: { isBreakout: 'false', 'gl-listed': true }
  end

  def unkown_visibility_recording
    dummy_recording published: false, protected: [true, false].sample, metadata: { isBreakout: 'false', 'gl-listed': [true, false].sample }
  end
end
