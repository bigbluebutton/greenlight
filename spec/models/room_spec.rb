# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Room, type: :model do
  describe 'before_validations' do
    let!(:room) { create(:room) }

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
