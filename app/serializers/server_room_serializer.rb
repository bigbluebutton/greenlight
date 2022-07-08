# frozen_string_literal: true

class ServerRoomSerializer < RoomSerializer
  attributes :owner, :status, :participants

  def owner
    object.user.name
  end
end
