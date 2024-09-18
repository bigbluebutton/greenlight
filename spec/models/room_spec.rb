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

RSpec.describe Room, type: :model do
  let(:room) { create(:room) }

  describe 'validations' do
    subject { create(:room) }

    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:recordings).dependent(:destroy) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_least(1).is_at_most(255) }
    it { is_expected.to validate_numericality_of(:recordings_processing).only_integer.is_greater_than_or_equal_to(0) }

    # Can't test validation on friendly_id, meeting_id and voice_brige due to before_validations

    context 'presentation validations' do
      it 'fails if the presentation is not a valid extension' do
        room = build(:room, presentation: fixture_file_upload(file_fixture('default-pdf.gif'), 'gif'))
        expect(room).to be_invalid
      end

      it 'fails if the presentation is too large' do
        room = build(:room, presentation: fixture_file_upload(file_fixture('large-pdf.pdf'), 'pdf'))
        expect(room).to be_invalid
      end
    end
  end

  describe 'scopes' do
    context 'with_provider' do
      it 'only includes users with the specified provider' do
        user1 = create(:user, provider: 'greenlight')
        role_with_provider_test = create(:role, provider: 'test')
        user2 = create(:user, provider: 'test', role: role_with_provider_test)

        create_list(:room, 5, user: user1)
        create_list(:room, 5, user: user2)

        rooms = described_class.includes(:user).with_provider('greenlight')
        expect(rooms.count).to eq(5)
        expect(rooms.pluck(:provider).uniq).to eq(['greenlight'])
      end
    end
  end

  describe 'before_validations' do
    describe '#set_friendly_id' do
      it 'sets a rooms friendly_id before creating' do
        expect(room.friendly_id).to be_present
      end

      it 'prevents duplicate friendly_ids' do
        duplicate_room = create(:room)
        expect { duplicate_room.friendly_id = room.friendly_id }.to change { duplicate_room.valid? }.to false
      end
    end

    describe '#set_meeting_id' do
      it 'sets a rooms meeting_id before creating' do
        expect(room.meeting_id).to be_present
      end

      it 'prevents duplicate meeting_ids' do
        duplicate_room = create(:room)
        expect { duplicate_room.meeting_id = room.meeting_id }.to change { duplicate_room.valid? }.to false
      end
    end

    describe '#set_voice_brige' do
      it 'sets a rooms voice_brige before creating' do
        if Rails.application.config.voice_bridge_phone_number.nil?
          expect(room.voice_bridge).to be_nil
        else
          expect(room.voice_bridge).to be_present
        end
      end

      it 'prevents duplicate voice_briges' do
        duplicate_room = create(:room)
        unless Rails.application.config.voice_bridge_phone_number.nil?
          expect { duplicate_room.voice_bridge = room.voice_bridge }.to change { duplicate_room.valid? }.to false
        end
      end
    end
  end

  describe 'before_save' do
    describe '#scan_presentation_for_virus' do
      let(:room) { create(:room) }

      before do
        allow_any_instance_of(described_class).to receive(:virus_scan?).and_return(true)
      end

      it 'makes a call to ClamAV if CLAMAV_SCANNING=true' do
        expect(Clamby).to receive(:safe?)

        room.presentation.attach(fixture_file_upload(file_fixture('default-avatar.png'), 'image/png'))
      end

      it 'adds an error if the file is not safe' do
        allow(Clamby).to receive(:safe?).and_return(false)
        room.presentation.attach(fixture_file_upload(file_fixture('default-avatar.png'), 'image/png'))
        expect(room.errors[:presentation]).to eq(['MalwareDetected'])
      end

      it 'does not makes a call to ClamAV if the image is not changing' do
        expect(Clamby).not_to receive(:safe?)

        room.update(name: 'New Name')
      end

      it 'does not makes a call to ClamAV if CLAMAV_SCANNING=false' do
        allow_any_instance_of(described_class).to receive(:virus_scan?).and_return(false)

        expect(Clamby).not_to receive(:safe?)

        room.presentation.attach(fixture_file_upload(file_fixture('default-avatar.png'), 'image/png'))
      end
    end
  end

  context 'after_create' do
    describe 'create_meeting_options' do
      let!(:viewer_access_code) { create(:meeting_option, name: 'glViewerAccessCode', default_value: '') }
      let!(:moderator_access_code) { create(:meeting_option, name: 'glModeratorAccessCode', default_value: '') }
      let!(:meeting_options) { create_list(:meeting_option, 4) }

      it 'creates a RoomMeetingOption for each MeetingOption' do
        expect { create(:room) }.to change(RoomMeetingOption, :count).from(0).to(6)
      end

      it 'does not generate an access code if the room config is not enabled' do
        create(:room)
        expect(RoomMeetingOption.find_by(meeting_option: viewer_access_code).value).to eql('')
      end

      context 'room configs' do
        it 'sets the meeting option settings correctly based on the room configs' do
          create(:rooms_configuration, meeting_option: meeting_options[0], value: 'true')
          create(:rooms_configuration, meeting_option: meeting_options[1], value: 'false')
          create(:rooms_configuration, meeting_option: meeting_options[2], value: 'optional')
          create(:rooms_configuration, meeting_option: meeting_options[3], value: 'default_enabled')

          create(:room)

          expect(RoomMeetingOption.find_by(meeting_option: meeting_options[0]).value).to eq('true')
          expect(RoomMeetingOption.find_by(meeting_option: meeting_options[1]).value).to eq(meeting_options[1].default_value)
          expect(RoomMeetingOption.find_by(meeting_option: meeting_options[2]).value).to eq(meeting_options[2].default_value)
          expect(RoomMeetingOption.find_by(meeting_option: meeting_options[3]).value).to eq('true')
        end

        context 'when access code room config is enabled' do
          before do
            create(:rooms_configuration, provider: 'greenlight', value: 'true', meeting_option: viewer_access_code)
            create(:rooms_configuration, provider: 'greenlight', value: 'true', meeting_option: moderator_access_code)
          end

          it 'creates a room and generates an access code if enabled' do
            create(:room)
            expect(RoomMeetingOption.find_by(meeting_option: viewer_access_code).value).not_to eql('')
          end

          it 'creates a room and generates both access code if both are enabled' do
            create(:room)
            expect(RoomMeetingOption.find_by(meeting_option: viewer_access_code).value).not_to eql('')
            expect(RoomMeetingOption.find_by(meeting_option: moderator_access_code).value).not_to eql('')
          end
        end

        context 'when access code room config is optional' do
          before do
            create(:rooms_configuration, provider: 'greenlight', value: 'optional', meeting_option: viewer_access_code)
          end

          it 'does not generate an access code' do
            create(:room)
            expect(RoomMeetingOption.find_by(meeting_option: viewer_access_code).value).to eql('')
          end
        end
      end
    end
  end

  context 'instance methods' do
    describe '#get_setting' do
      it 'fetches a room setting by :name' do
        room = create(:room)
        meeting_option = create(:meeting_option, name: 'setting')
        room_meeting_option = create(:room_meeting_option, room:, meeting_option:)

        expect(room.get_setting(name: 'setting')).to eq(room_meeting_option)
      end

      it 'returns nil for unfound setting' do
        room = create(:room)

        expect(room.get_setting(name: '404')).to be_nil
      end
    end

    describe '#public_recordings' do
      let(:public_recordings) do
        [
          create(:recording, room:, visibility: Recording::VISIBILITIES[:public]),
          create(:recording, room:, visibility: Recording::VISIBILITIES[:public_protected])
        ]
      end

      before do
        [Recording::VISIBILITIES[:unpublished], Recording::VISIBILITIES[:published], Recording::VISIBILITIES[:protected]].each do |visibility|
          create(:recording, room:, visibility:)
        end
      end

      it 'retuns filters out the room public recordings' do
        expect(room.public_recordings).to match_array(public_recordings)
      end
    end
  end
end
