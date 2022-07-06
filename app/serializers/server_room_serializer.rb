# frozen_string_literal: true

class ServerRoomSerializer < RoomSerializer
  attributes :owner, :status, :participants

  def owner
    object.user.name
  end

  def status
    @instance_options[:options][:active_server_rooms].each do |room|
      return 'Active' if room.key?(object.meeting_id)
    end

    'Not Running'
  end

  def participants
    @instance_options[:options][:active_server_rooms].each do |room|
      return room[object.meeting_id] if room[object.meeting_id].present?
    end

    '-'
  end
end
