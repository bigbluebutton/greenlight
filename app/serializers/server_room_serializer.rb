# frozen_string_literal: true

class ServerRoomSerializer < RoomSerializer
  attributes :owner, :active, :participants

  def owner
    object.user.name
  end
end
