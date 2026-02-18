# frozen_string_literal: true

class PopulateVoiceBrigeForExistingRooms < ActiveRecord::Migration[7.0]
  def up
    return if Rails.application.config.voice_bridge_phone_number.nil?

    pin_len = Rails.application.config.sip_pin_length
    max_pins = 10.pow(pin_len) - 10.pow(pin_len - 1) - 1

    raise 'The db contains to many rooms to assign each one a unique voice_bridge' if Room.all.length > max_pins

    Room.where(voice_bridge: nil).each do |room|
      id = SecureRandom.random_number(max_pins) + 10.pow(pin_len - 1)

      while Room.exists?(voice_bridge: id)
        id += 1
        id = 10.pow(pin_len - 1) if id > max_pins
      end

      room.update(voice_bridge: id)
    end
  end

  def down
    # rubocop:disable Rails/SkipsModelValidations
    Room.update_all(voice_bridge: nil)
    # rubocop:enable Rails/SkipsModelValidations
  end
end
