# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MeetingOption, type: :model do
  describe 'validations' do
    it { is_expected.to have_many(:room_meeting_options).dependent(:restrict_with_exception) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end

  describe '#bbb_options' do
    it 'returns all non-greenlight options' do
      room = create(:room)
      setting1 = create(:meeting_option, name: 'glSetting1')
      setting2 = create(:meeting_option, name: 'glSetting2')
      setting3 = create(:meeting_option, name: 'setting1')
      setting4 = create(:meeting_option, name: 'setting2')

      create(:room_meeting_option, room:, meeting_option: setting1)
      create(:room_meeting_option, room:, meeting_option: setting2)
      room_option1 = create(:room_meeting_option, room:, meeting_option: setting3, value: 'value1')
      room_option2 = create(:room_meeting_option, room:, meeting_option: setting4, value: 'value2')

      expect(
        described_class.bbb_options(room_id: room.id)
      ).to eq([
                [setting3.name, room_option1.value],
                [setting4.name, room_option2.value]
              ])
    end
  end

  describe '#get_value' do
    it 'returns the room meeting option for a room by name' do
      room = create(:room)

      meeting_option1 = create(:meeting_option, name: 'setting')
      create(:room_meeting_option, room:, meeting_option: meeting_option1, value: 'value1')

      room_meeting_option = described_class.get_value(name: 'setting', room_id: room.id)

      expect(room_meeting_option.value).to eq('value1')
    end

    it 'returns nil for unfound room meeting option' do
      expect(
        described_class.get_value(name: 'notASettingTrustMe', room_id: 'YouAlreadyTrustedMe')
      ).to be_nil
    end
  end
end
