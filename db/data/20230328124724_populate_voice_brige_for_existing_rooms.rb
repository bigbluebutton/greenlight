# frozen_string_literal: true

class PopulateVoiceBrigeForExistingRooms < ActiveRecord::Migration[7.0]
  def up
    if Rails.application.config.voice_bridge_phone_number == nil
      return
    end

    if Room.all.length > 89999
      raise "The db contains to many rooms to assign each one a unique voice_bridge"
    end

    Room.where(voice_bridge: nil).each do |room|
      id = SecureRandom.random_number((10.pow(5)) - 1)

      if id < 10000
        id = id + 10000
      end

      while Room.exists?(voice_bridge: id)
        id = id + 1
        if id >= 99999
          id = 10000
        end
      end
      
      room.update(voice_bridge: id)
    end
  end

  def down
    Room.update_all(voice_bridge: nil)
  end
end
