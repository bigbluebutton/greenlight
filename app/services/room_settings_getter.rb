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

class RoomSettingsGetter
  # Special options are meeting options that have different values other than `true|false` to represent postives and negatives.
  # The `special_options` hash is a registry that keeps hold of all of the special options used in GL3 along with their postive and negative values.
  # When adding a new special option just register it in this Hash respecting the fallowing format:
  # Hash(`<option_name> => {'true' => <Postive>, 'false' => <Negative>})`
  SPECIAL_OPTIONS = { 'guestPolicy' => { 'true' => 'ASK_MODERATOR', 'false' => 'ALWAYS_ACCEPT' } }.freeze

  def initialize(room_id:, provider:, current_user:, settings: [], show_codes: false, only_enabled: false, only_bbb_options: false, voice_bridge: nil)
    @current_user = current_user
    @room_id = room_id
    @only_bbb_options = only_bbb_options # When used only BBB options (not prefixed with 'gl') will be returned.
    @only_enabled = only_enabled # When used only optional and force enabled options will be returned.
    @show_codes = show_codes # When used access code values will be returned.
    @settings = settings # When given only the settings contained in the Array<String> will be returned.
    @voice_bridge = voice_bridge

    # Fetching only rooms configs that are not optional to overwrite the settings values.
    @rooms_configs = MeetingOption.joins(:rooms_configurations)
                                  .where(rooms_configurations: { provider: })
                                  .where.not(rooms_configurations: { value: %w[optional default_enabled] })
                                  .pluck(:name, :value)
                                  .to_h
  end

  def call
    room_settings = MeetingOption.joins(:room_meeting_options).where(room_meeting_options: { room_id: @room_id })
    room_settings = room_settings.where(name: @settings) unless @settings.empty?
    room_settings = room_settings.where.not('name ILIKE :prefix', prefix: 'gl%') if @only_bbb_options
    room_settings = room_settings.pluck(:name, :value).to_h

    access_codes = room_settings.slice('glViewerAccessCode', 'glModeratorAccessCode') # Holding room original access code values.

    @rooms_configs.slice!(*room_settings.keys) # Keeping only room settings related configs.
    room_settings.merge!(@rooms_configs) # Merging rooms settings with their **none** optional configs.

    filter_disabled(room_settings:) if @only_enabled # Only enabled(optional|force enabled) setting values will be returned.
    infer_specials(room_settings:) # Special options should map their forced values to what was configured in `SPECIAL_OPTIONS` registry.
    infer_codes(room_settings:, access_codes:) # Access codes should map their forced values as intended.
    infer_can_record(room_settings:) if room_settings['record'] && @rooms_configs['record'].nil?

    set_voice_brige(room_settings:)

    room_settings
  end

  private

  def filter_disabled(room_settings:)
    disabled_settings = @rooms_configs.filter { |_k, v| v == 'false' }
    room_settings.except!(*disabled_settings.keys)
  end

  def infer_specials(room_settings:)
    room_settings_special_options = SPECIAL_OPTIONS.slice(*room_settings.keys) # Extracting the room settings special options to minimize iterations.

    # Configs are enum of ['true', 'false', 'optional'], after merging none optional settings with their configs only the room
    # special options have to map positive/negative values.
    room_settings_special_options.each_key do |name|
      config = room_settings[name]
      room_settings[name] = SPECIAL_OPTIONS[name][config] if %w[true false].include? config # Config values are expected to be 'true'|'false'
    end
  end

  def infer_codes(room_settings:, access_codes:)
    filtered_access_codes = access_codes.slice(*room_settings.keys) # Filtering the available room access codes to minimize iterations.

    filtered_access_codes.each do |key, code|
      room_settings[key] = case room_settings[key]
                           when 'false'
                             '' # Forced disabled access code will have an empty value.
                           else
                             code # Forced enabled or optional access code will conserve its original value.
                           end

      room_settings[key] = room_settings[key].present? unless @show_codes # Hiding access code values.
    end
  end

  def infer_can_record(room_settings:)
    # checking if CanRecord permission is set to true when RoomConfig record is optional
    return unless @current_user
    return if RolePermission.joins(:permission).find_by(role_id: @current_user&.role_id, permission: { name: 'CanRecord' })&.value == 'true'

    room_settings['record'] = 'false'
  end

  def set_voice_brige(room_settings:)
    if @voice_bridge != nil
      room_settings['voiceBridge'] = "#{@voice_bridge}"
    end
  end
end
