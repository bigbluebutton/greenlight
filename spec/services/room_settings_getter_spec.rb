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

describe RoomSettingsGetter, type: :service do
  let(:user) { create(:user) }

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

        res = described_class.new(room_id: room.id, current_user: user, provider: 'greenlight').call

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

        res = described_class.new(room_id: room.id, current_user: user, provider: 'greenlight').call

        expect(res).to eq({
                            'glSpecial!' => 'SPECIAL_FORCE',
                            'glSpecialToo!!' => 'SPECIAL',
                            'KingOfSpecials!!!' => 'NOT_SPECIAL'
                          })
      end
    end

    context 'access codes' do
      it 'returns an empty code for forced disabled access codes' do
        room = create(:room)
        viewer_access_code = create(:meeting_option, name: 'glViewerAccessCode')
        moderator_access_code = create(:meeting_option, name: 'glModeratorAccessCode')
        setting = create(:meeting_option, name: 'setting')

        create(:room_meeting_option, room:, meeting_option: viewer_access_code, value: 'VIEWER')
        create(:room_meeting_option, room:, meeting_option: moderator_access_code, value: 'MODERATOR')
        create(:room_meeting_option, room:, meeting_option: setting, value: 'VALUE')

        create(:rooms_configuration, meeting_option: viewer_access_code, provider: 'greenlight', value: 'false')
        create(:rooms_configuration, meeting_option: moderator_access_code, provider: 'greenlight', value: 'false')
        create(:rooms_configuration, meeting_option: setting, provider: 'greenlight', value: 'optional')

        res = described_class.new(room_id: room.id, current_user: user, provider: 'greenlight', show_codes: true).call

        expect(res).to eq({
                            'setting' => 'VALUE',
                            'glViewerAccessCode' => '',
                            'glModeratorAccessCode' => ''
                          })
      end

      it 'returns access code value when enabled (optional|forced enabled)' do
        room = create(:room)
        viewer_access_code = create(:meeting_option, name: 'glViewerAccessCode')
        moderator_access_code = create(:meeting_option, name: 'glModeratorAccessCode')
        setting = create(:meeting_option, name: 'setting')

        create(:room_meeting_option, room:, meeting_option: viewer_access_code, value: 'VIEWER')
        create(:room_meeting_option, room:, meeting_option: moderator_access_code, value: 'MODERATOR')
        create(:room_meeting_option, room:, meeting_option: setting, value: 'VALUE')

        create(:rooms_configuration, meeting_option: viewer_access_code, provider: 'greenlight', value: 'true')
        create(:rooms_configuration, meeting_option: moderator_access_code, provider: 'greenlight', value: 'optional')
        create(:rooms_configuration, meeting_option: setting, provider: 'greenlight', value: 'optional')

        res = described_class.new(room_id: room.id, current_user: user, provider: 'greenlight', show_codes: true).call

        expect(res).to eq({
                            'setting' => 'VALUE',
                            'glViewerAccessCode' => 'VIEWER',
                            'glModeratorAccessCode' => 'MODERATOR'
                          })
      end

      describe 'options' do
        context ':show_codes' do
          it 'returns a filtered Hash("name" => "value") of room settings with access codes values hidden' do
            room = create(:room)
            viewer_access_code = create(:meeting_option, name: 'glViewerAccessCode')
            moderator_access_code = create(:meeting_option, name: 'glModeratorAccessCode')
            setting = create(:meeting_option, name: 'setting')

            create(:room_meeting_option, room:, meeting_option: viewer_access_code, value: 'FILLED')
            create(:room_meeting_option, room:, meeting_option: moderator_access_code, value: '')
            create(:room_meeting_option, room:, meeting_option: setting, value: 'VALUE')

            create(:rooms_configuration, meeting_option: viewer_access_code, provider: 'greenlight', value: 'true')
            create(:rooms_configuration, meeting_option: moderator_access_code, provider: 'greenlight', value: 'optional')
            create(:rooms_configuration, meeting_option: setting, provider: 'greenlight', value: 'optional')

            res = described_class.new(room_id: room.id, current_user: user, provider: 'greenlight', show_codes: false).call

            expect(res).to eq({
                                'setting' => 'VALUE',
                                'glViewerAccessCode' => true,
                                'glModeratorAccessCode' => false
                              })
          end
        end

        context ':only_bbb_options' do
          it 'returns a filtered Hash("name" => "value") of room settings that does not start with "gl" prefix' do
            room = create(:room)
            setting1 = create(:meeting_option, name: 'glSetting')
            setting2 = create(:meeting_option, name: 'GlGLSetting')
            setting3 = create(:meeting_option, name: 'YourOnlyBBBSetting')

            create(:room_meeting_option, room:, meeting_option: setting1, value: 'GL')
            create(:room_meeting_option, room:, meeting_option: setting2, value: 'GL')
            create(:room_meeting_option, room:, meeting_option: setting3, value: 'BBB')

            create(:rooms_configuration, meeting_option: setting1, provider: 'greenlight', value: 'true')
            create(:rooms_configuration, meeting_option: setting2, provider: 'greenlight', value: 'false')
            create(:rooms_configuration, meeting_option: setting3, provider: 'greenlight', value: 'optional')

            res = described_class.new(room_id: room.id, current_user: user, provider: 'greenlight', only_bbb_options: true).call

            expect(res).to eq({
                                'YourOnlyBBBSetting' => 'BBB'
                              })
          end
        end

        context ':only_enabled' do
          it 'returns a filtered Hash("name => "value") of room settings that are not forced disabled (optional|forced enabled)' do
            room = create(:room)
            setting1 = create(:meeting_option, name: 'disabledOne')
            setting2 = create(:meeting_option, name: 'disabledTwo')
            setting3 = create(:meeting_option, name: 'forcedEnabled')
            setting4 = create(:meeting_option, name: 'optional')

            create(:room_meeting_option, room:, meeting_option: setting1, value: 'disabled')
            create(:room_meeting_option, room:, meeting_option: setting2, value: 'disabled')
            create(:room_meeting_option, room:, meeting_option: setting3, value: 'enabled')
            create(:room_meeting_option, room:, meeting_option: setting4, value: 'optional')

            create(:rooms_configuration, meeting_option: setting1, provider: 'greenlight', value: 'false')
            create(:rooms_configuration, meeting_option: setting2, provider: 'greenlight', value: 'false')
            create(:rooms_configuration, meeting_option: setting3, provider: 'greenlight', value: 'true')
            create(:rooms_configuration, meeting_option: setting4, provider: 'greenlight', value: 'optional')

            res = described_class.new(room_id: room.id, current_user: user, provider: 'greenlight', only_enabled: true).call

            expect(res).to eq({
                                'forcedEnabled' => 'true',
                                'optional' => 'optional'
                              })
          end
        end

        context ':settings' do
          it 'returns a filtered Hash("name => "value") of mentionned room settings only' do
            room = create(:room)
            setting1 = create(:meeting_option, name: 'One')
            setting2 = create(:meeting_option, name: 'Two')
            setting3 = create(:meeting_option, name: 'Three')

            create(:room_meeting_option, room:, meeting_option: setting1, value: 'enabled')
            create(:room_meeting_option, room:, meeting_option: setting2, value: 'optional')
            create(:room_meeting_option, room:, meeting_option: setting3, value: 'disabled')

            create(:rooms_configuration, meeting_option: setting1, provider: 'greenlight', value: 'true')
            create(:rooms_configuration, meeting_option: setting2, provider: 'greenlight', value: 'optional')
            create(:rooms_configuration, meeting_option: setting3, provider: 'greenlight', value: 'false')

            res = described_class.new(room_id: room.id, current_user: user, provider: 'greenlight', settings: %w[One Three]).call

            expect(res).to eq({
                                'One' => 'true',
                                'Three' => 'false'
                              })
          end
        end

        context ':room_configuration infer_can_record cases' do
          it 'room_setting record value changes to false if room_configuration record value is optional and CanRecord permission is set to false' do
            room = create(:room)
            user = create(:user, :without_can_record_permission)
            setting1 = create(:meeting_option, name: 'record')

            create(:room_meeting_option, room:, meeting_option: setting1, value: 'true')

            create(:rooms_configuration, meeting_option: setting1, provider: 'greenlight', value: 'optional')

            res = described_class.new(room_id: room.id, current_user: user, provider: 'greenlight', settings: ['record']).call

            expect(res).to eq({
                                'record' => 'false'
                              })
          end

          it 'room_setting record value remains true if room_configuration record value is optional and CanRecord permission is set to true' do
            RolePermission.find_or_create_by(role: user.role, permission: Permission.find_or_create_by(name: 'CanRecord')).update(value: 'true')

            room = create(:room)
            setting1 = create(:meeting_option, name: 'record')

            create(:room_meeting_option, room:, meeting_option: setting1, value: 'true')

            create(:rooms_configuration, meeting_option: setting1, provider: 'greenlight', value: 'optional')

            res = described_class.new(room_id: room.id, current_user: user, provider: 'greenlight', settings: ['record']).call

            expect(res).to eq({
                                'record' => 'true'
                              })
          end

          it 'room_setting record value remains the same if room_configuration record value is set to true or false' do
            room = create(:room)
            setting1 = create(:meeting_option, name: 'record')

            create(:room_meeting_option, room:, meeting_option: setting1, value: 'true')

            create(:rooms_configuration, meeting_option: setting1, provider: 'greenlight', value: 'true')

            res = described_class.new(room_id: room.id, current_user: user, provider: 'greenlight', settings: ['record']).call

            expect(res).to eq({
                                'record' => 'true'
                              })
          end
        end
      end
    end
  end
end
