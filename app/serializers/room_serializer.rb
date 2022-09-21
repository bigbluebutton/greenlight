# frozen_string_literal: true

class RoomSerializer < ApplicationSerializer
  attributes :id, :name, :friendly_id, :last_session, :created_at, :active, :participants
  attribute :shared_owner, if: -> { object.shared }
  attribute :last_session, if: -> { object.last_session }

  def shared_owner
    object.user.name
  end

  def last_session
    object.last_session.strftime('%A %B %e, %Y %l:%M%P')
  end
end
