# frozen_string_literal: true

class PopulateVoiceBrigeForExistingRooms < ActiveRecord::Migration[7.0]
  def up
    if Rails.application.config.voice_bridge_phone_number == nil
      return
    end
    i = 0
    Room.where(voice_bridge: nil).each do |room|
      while Room.where(voice_bridge: 10000+i).length > 0
        i = i + 1
        if i >= 99999
          raise "The db contains to many rooms to assign each one a unique voice_brige"
        end
      end
      room.update(voice_bridge: 10000 + i)
      i = i + 1
    end
  end

  def down
    Room.update_all(voice_bridge: nil)
  end
end
