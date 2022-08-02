# frozen_string_literal: true

class RoomSettingsGetter
  # Special options are meeting options that have different values other than `true|false` to represent postives and negatives.
  # The `special_options` hash is a registry that keeps hold of all of the special options used in GL3 along with their postive and negative values.
  # When adding a new special option just register it in this Hash respecting the fallowing format:
  # Hash(`<option_name> => {'true' => <Postive>, 'false' => <Negative>})`
  SPECIAL_OPTIONS = { 'guestPolicy' => { 'true' => 'ASK_MODERATOR', 'false' => 'ALWAYS_ACCEPT' } }.freeze

  def initialize(room_id:, provider:, only_bbb_options: false)
    @room_id = room_id
    @only_bbb_options = only_bbb_options
    # Fetching only rooms configs that are not optional to overwrite the settings values.
    @rooms_configs = MeetingOption.joins(:rooms_configurations)
                                  .where(rooms_configurations: { provider: })
                                  .where.not(rooms_configurations: { value: 'optional' })
                                  .pluck(:name, :value)
                                  .to_h
  end

  def call
    room_settings = MeetingOption.joins(:room_meeting_options).where(room_meeting_options: { room_id: @room_id })
    room_settings = room_settings.where.not('name ILIKE :prefix', prefix: 'gl%') if @only_bbb_options
    room_settings = room_settings.pluck(:name, :value).to_h

    room_settings.merge!(@rooms_configs) # Merging rooms settings with its none optional configurations prioritizing forced configs over settings.
    room_settings_special_options = SPECIAL_OPTIONS.slice(*room_settings.keys) # Extracting the room settings special options to minimize iterations.

    # Configs are enum of ['true', 'false', 'optional'], after merging none optional settings with their configs only the room
    # special options have to map positive/negative values.
    room_settings_special_options.each_key do |name|
      config = room_settings[name]
      room_settings[name] = SPECIAL_OPTIONS[name][config] if %w[true false].include? config # Config values are expected to be 'true'|'false'
    end

    room_settings
  end
end
