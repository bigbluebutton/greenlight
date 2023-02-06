# frozen_string_literal: true

class ServerRoomSerializer < RoomSerializer
  attributes :owner, :online, :participants, :last_session

  def owner
    object.user.name
  end
end
