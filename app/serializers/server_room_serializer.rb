# frozen_string_literal: true

class ServerRoomSerializer < RoomSerializer
  attributes :owner, :active, :participants, :last_session

  def owner
    object.user.name
  end

  def last_session
    return 'No meeting yet' if object.last_session.nil?

    last_session_date = object.last_session.strftime('%B %e, %Y')
    object.status == 'Active' ? "Started: #{last_session_date}" : "Ended: #{last_session_date}"
  end
end
