# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Room, type: :model do
  let!(:room) { create(:room) }

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

  describe '#anyone_joins_as_moderator?' do
    let!(:room) { create(:room) }

    it 'calls MeetingOption::get_value and returns true if "glAnyoneJoinAsModerator" is set to "true"' do
      allow(MeetingOption).to receive(:get_value).and_return(instance_double(RoomMeetingOption, value: 'true'))
      expect(MeetingOption).to receive(:get_value).with(name: 'glAnyoneJoinAsModerator', room_id: room.id)

      expect(room).to be_anyone_joins_as_moderator
    end

    it 'calls MeetingOption::get_value and returns false if "glAnyoneJoinAsModerator" is NOT set to "true"' do
      allow(MeetingOption).to receive(:get_value).and_return(instance_double(RoomMeetingOption, value: 'false'))
      expect(MeetingOption).to receive(:get_value).with(name: 'glAnyoneJoinAsModerator', room_id: room.id)

      expect(room).not_to be_anyone_joins_as_moderator
    end

    it 'calls MeetingOption::get_value and returns false if "glAnyoneJoinAsModerator" is NOT set' do
      allow(MeetingOption).to receive(:get_value).and_return(nil)
      expect(MeetingOption).to receive(:get_value).with(name: 'glAnyoneJoinAsModerator', room_id: room.id)

      expect(room).not_to be_anyone_joins_as_moderator
    end
  end

  describe 'private methods' do
    describe '#generate_code' do
      before do
        allow_any_instance_of(described_class).to receive(:generate_code).and_call_original
      end

      it 'calls SecureRandom#alphanumeric(6) and downcase its returned value' do
        allow(SecureRandom).to receive(:alphanumeric).and_return('TEST')
        expect(SecureRandom).to receive(:alphanumeric).with(6)
        expect(room.generate_code).to eq('test')
      end
    end
  end

  describe '#viewer_access_code' do
    it 'calls #get_setting with name "glViewerAccessCode" and returns the value' do
      allow_any_instance_of(described_class).to receive(:get_setting).and_return(instance_double(RoomMeetingOption, value: 'CODE'))
      expect_any_instance_of(described_class).to receive(:get_setting).with(name: 'glViewerAccessCode')

      expect(room.viewer_access_code).to eq('CODE')
    end
  end

  describe '#moderator_access_code' do
    it 'calls #get_setting with name "glModeratorAccessCode" and returns the value' do
      allow_any_instance_of(described_class).to receive(:get_setting).and_return(instance_double(RoomMeetingOption, value: 'CODE'))
      expect_any_instance_of(described_class).to receive(:get_setting).with(name: 'glModeratorAccessCode')

      expect(room.moderator_access_code).to eq('CODE')
    end
  end

  describe '#generate_viewer_access_code' do
    it 'calls #get_setting with name "glViewerAccessCode" and update it with #generate_code' do
      fake_room_meeting_option = instance_double(RoomMeetingOption)

      allow(fake_room_meeting_option).to receive(:update).and_return true
      allow_any_instance_of(described_class).to receive(:get_setting).and_return(fake_room_meeting_option)
      allow_any_instance_of(described_class).to receive(:generate_code).and_return('NEW_CODE')

      expect_any_instance_of(described_class).to receive(:get_setting).with(name: 'glViewerAccessCode')
      expect_any_instance_of(described_class).to receive(:generate_code)
      expect(fake_room_meeting_option).to receive(:update).with value: 'NEW_CODE'

      room.generate_viewer_access_code
    end
  end

  describe '#generate_moderator_access_code' do
    it 'calls #get_setting with name "glModeratorAccessCode" and update it with #generate_code' do
      fake_room_meeting_option = instance_double(RoomMeetingOption)
      allow(fake_room_meeting_option).to receive(:update).and_return true
      allow_any_instance_of(described_class).to receive(:get_setting).and_return(fake_room_meeting_option)
      allow_any_instance_of(described_class).to receive(:generate_code).and_return('NEW_CODE')

      expect_any_instance_of(described_class).to receive(:get_setting).with(name: 'glModeratorAccessCode')
      expect_any_instance_of(described_class).to receive(:generate_code)
      expect(fake_room_meeting_option).to receive(:update).with value: 'NEW_CODE'

      room.generate_moderator_access_code
    end
  end

  describe '#remove_moderator_access_code' do
    it 'calls #get_setting with name "glModeratorAccessCode" and update it with nil' do
      fake_room_meeting_option = instance_double(RoomMeetingOption)
      allow(fake_room_meeting_option).to receive(:update).and_return true
      allow_any_instance_of(described_class).to receive(:get_setting).and_return(fake_room_meeting_option)

      expect_any_instance_of(described_class).to receive(:get_setting).with(name: 'glModeratorAccessCode')
      expect(fake_room_meeting_option).to receive(:update).with value: nil

      room.remove_moderator_access_code
    end
  end

  describe '#remove_viewer_access_code' do
    it 'calls #get_setting with name "glViewerAccessCode" and update it with nil' do
      fake_room_meeting_option = instance_double(RoomMeetingOption)
      allow(fake_room_meeting_option).to receive(:update).and_return true
      allow_any_instance_of(described_class).to receive(:get_setting).and_return(fake_room_meeting_option)

      expect_any_instance_of(described_class).to receive(:get_setting).with(name: 'glViewerAccessCode')
      expect(fake_room_meeting_option).to receive(:update).with value: nil

      room.remove_viewer_access_code
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

  describe 'after_create' do
    describe 'create_meeting_options' do
      it 'creates a RoomMeetingOption for each MeetingOption' do
        create_list(:meeting_option, 5)

        expect { create(:room) }.to change(RoomMeetingOption, :count).from(0).to(5)
      end
    end
  end

  describe 'validations' do
    subject { create(:room) }

    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:recordings).dependent(:destroy) }
    it { is_expected.to validate_presence_of(:name) }
    # Can't test validation on friendly_id and meeting_id due to before_validations
  end
end
