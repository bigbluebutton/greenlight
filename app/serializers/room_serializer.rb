# frozen_string_literal: true

class RoomSerializer < ApplicationSerializer
  attributes :id, :name, :friendly_id, :online, :participants, :last_session

  attribute :shared_owner, if: -> { object.shared }
  # attribute :last_session, if: -> { object.last_session }

  def shared_owner
    object.user.name
  end

  def last_session
    object.last_session&.strftime('%B %e, %Y %l:%M%P')
  end
end
