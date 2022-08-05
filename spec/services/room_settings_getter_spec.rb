# frozen_string_literal: true

require 'rails_helper'

describe RoomSettingsGetter, type: :service do
  describe '#call' do
    context 'Normal room settings' do
      it 'returns a Hash("name" => "value") of room settings according to the configurations' do
        room = create(:room)
        setting1 = create(:meeting_option, name: 'glSetting1')
        setting2 = create(:meeting_option, name: 'glSetting2')
        setting3 = create(:meeting_option, name: 'setting3')

        create(:room_meeting_option, room:, meeting_option: setting1, value: 'value1')
        create(:room_meeting_option, room:, meeting_option: setting2, value: 'value2')
        create(:room_meeting_option, room:, meeting_option: setting3, value: 'value3')

        create(:rooms_configuration, meeting_option: setting1, provider: 'greenlight', value: 'true')
        create(:rooms_configuration, meeting_option: setting2, provider: 'greenlight', value: 'optional')
        create(:rooms_configuration, meeting_option: setting3, provider: 'greenlight', value: 'false')

        res = described_class.new(room_id: room.id, provider: 'greenlight').call

        expect(res).to eq({
                            'glSetting1' => 'true',
                            'glSetting2' => 'value2',
                            'setting3' => 'false'
                          })
      end
    end

    context 'special room settings' do
      it 'returns a Hash("name" => "value") of room settings according to the configurations' do
        stub_const('RoomSettingsGetter::SPECIAL_OPTIONS', {
                     'glSpecial!' => { 'true' => 'SPECIAL_FORCE', 'false' => 'NOT_SPECIAL' },
                     'glSpecialToo!!' => { 'true' => 'SPECIAL_FORCE', 'false' => 'NOT_SPECIAL' },
                     'KingOfSpecials!!!' => { 'true' => 'SPECIAL_FORCE', 'false' => 'NOT_SPECIAL' }
                   })
        room = create(:room)
        setting1 = create(:meeting_option, name: 'glSpecial!')
        setting2 = create(:meeting_option, name: 'glSpecialToo!!')
        setting3 = create(:meeting_option, name: 'KingOfSpecials!!!')

        create(:room_meeting_option, room:, meeting_option: setting1, value: 'SPECIAL')
        create(:room_meeting_option, room:, meeting_option: setting2, value: 'SPECIAL')
        create(:room_meeting_option, room:, meeting_option: setting3, value: 'SPECIAL')

        create(:rooms_configuration, meeting_option: setting1, provider: 'greenlight', value: 'true')
        create(:rooms_configuration, meeting_option: setting2, provider: 'greenlight', value: 'optional')
        create(:rooms_configuration, meeting_option: setting3, provider: 'greenlight', value: 'false')

        res = described_class.new(room_id: room.id, provider: 'greenlight').call

        expect(res).to eq({
                            'glSpecial!' => 'SPECIAL_FORCE',
                            'glSpecialToo!!' => 'SPECIAL',
                            'KingOfSpecials!!!' => 'NOT_SPECIAL'
                          })
      end
    end

    context 'bbb options only' do
      it 'returns a filtered Hash("name" => "value") of room settings that does not start with a :prefix' do
        room = create(:room)
        setting1 = create(:meeting_option, name: 'glSetting')
        setting2 = create(:meeting_option, name: 'GlGLSetting')
        setting3 = create(:meeting_option, name: 'YourOnlyBBBSetting')

        create(:room_meeting_option, room:, meeting_option: setting1, value: 'GL')
        create(:room_meeting_option, room:, meeting_option: setting2, value: 'GL')
        create(:room_meeting_option, room:, meeting_option: setting3, value: 'BBB')

        create(:rooms_configuration, meeting_option: setting1, provider: 'greenlight', value: 'optional')
        create(:rooms_configuration, meeting_option: setting2, provider: 'greenlight', value: 'optional')
        create(:rooms_configuration, meeting_option: setting3, provider: 'greenlight', value: 'optional')

        res = described_class.new(room_id: room.id, provider: 'greenlight', only_bbb_options: true).call

        expect(res).to eq({
                            'YourOnlyBBBSetting' => 'BBB'
                          })
      end
    end
  end
end
