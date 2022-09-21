# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MeetingOption, type: :model do
  describe 'validations' do
    it { is_expected.to have_many(:room_meeting_options).dependent(:restrict_with_exception) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end

  describe 'class methods' do
    describe '#get_setting_value' do
      context 'existing setting' do
        it 'returns the room meeting option value' do
          room = create(:room)

          meeting_option1 = create(:meeting_option, name: 'setting')
          create(:room_meeting_option, room:, meeting_option: meeting_option1, value: 'value1')

          room_meeting_option = described_class.get_setting_value(name: 'setting', room_id: room.id)

          expect(room_meeting_option.value).to eq('value1')
        end
      end

      context 'inexisting setting' do
        it 'returns nil' do
          expect(
            described_class.get_setting_value(name: 'notASettingTrustMe', room_id: 'YouAlreadyTrustedMe')
          ).to be_nil
        end
      end
    end

    describe '#get_config_value' do
      context 'existing configuration' do
        it 'returns the rooms configuration value' do
          meeting_option = create(:meeting_option, name: 'setting')
          create(:rooms_configuration, meeting_option:, provider: 'greenlight', value: 'optional')

          rooms_config = described_class.get_config_value(name: 'setting', provider: 'greenlight')
          expect(rooms_config['setting']).to eq('optional')
        end
      end

      context 'inexisting configuration' do
        it 'returns nil' do
          expect(
            described_class.get_config_value(name: 'notAConfigTrustMe', provider: 'YouShould\'ve')
          ).to be_empty
        end
      end
    end
  end
end
