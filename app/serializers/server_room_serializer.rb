# frozen_string_literal: true

class ServerRoomSerializer < RoomSerializer
  attributes :owner, :active, :participants, :last_session

  def owner
    object.user.name
  end

  def last_session
    object.last_session&.strftime('%B %e, %Y')
  end
end
