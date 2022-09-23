# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Room, type: :model do
  let(:room) { create(:room) }

  describe 'validations' do
    subject { create(:room) }

    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:recordings).dependent(:destroy) }
    it { is_expected.to validate_presence_of(:name) }
    # Can't test validation on friendly_id and meeting_id due to before_validations
  end

  describe 'scopes' do
    context 'with_provider' do
      it 'only includes users with the specified provider' do
        user1 = create(:user, provider: 'greenlight')
        user2 = create(:user, provider: 'test')

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
  end

  context 'after_create' do
    describe 'create_meeting_options' do
      let!(:viewer_access_code) { create(:meeting_option, name: 'glViewerAccessCode', default_value: '') }
      let!(:moderator_access_code) { create(:meeting_option, name: 'glModeratorAccessCode', default_value: '') }

      before do
        create_list(:meeting_option, 3)
      end

      it 'creates a RoomMeetingOption for each MeetingOption' do
        expect { create(:room) }.to change(RoomMeetingOption, :count).from(0).to(5)
      end

      it 'does not generate an access code if the room config is not enabled' do
        create(:room)
        expect(RoomMeetingOption.find_by(meeting_option: viewer_access_code).value).to eql('')
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

  context 'instance methods' do
    describe '#anyone_joins_as_moderator?' do
      let!(:room) { create(:room) }

      it 'calls MeetingOption::get_setting_value and returns true if "glAnyoneJoinAsModerator" is set to "true"' do
        allow(MeetingOption).to receive(:get_setting_value).and_return(instance_double(RoomMeetingOption, value: 'true'))
        expect(MeetingOption).to receive(:get_setting_value).with(name: 'glAnyoneJoinAsModerator', room_id: room.id)

        expect(room).to be_anyone_joins_as_moderator
      end

      it 'calls MeetingOption::get_setting_value and returns false if "glAnyoneJoinAsModerator" is NOT set to "true"' do
        allow(MeetingOption).to receive(:get_setting_value).and_return(instance_double(RoomMeetingOption, value: 'false'))
        expect(MeetingOption).to receive(:get_setting_value).with(name: 'glAnyoneJoinAsModerator', room_id: room.id)

        expect(room).not_to be_anyone_joins_as_moderator
      end

      it 'calls MeetingOption::get_setting_value and returns false if "glAnyoneJoinAsModerator" is NOT set' do
        allow(MeetingOption).to receive(:get_setting_value).and_return(nil)
        expect(MeetingOption).to receive(:get_setting_value).with(name: 'glAnyoneJoinAsModerator', room_id: room.id)

        expect(room).not_to be_anyone_joins_as_moderator
      end
    end

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
  end
end
