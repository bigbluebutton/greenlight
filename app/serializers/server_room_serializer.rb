# frozen_string_literal: true

class ServerRoomSerializer < RoomSerializer
  attributes :owner, :online, :participants, :last_session

  def owner
    object.user.name
  end

  def last_session
    object.last_session&.strftime('%A %B %e, %Y %l:%M%P')
  end
end
