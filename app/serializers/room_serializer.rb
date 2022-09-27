# frozen_string_literal: true

class RoomSerializer < ApplicationSerializer
  attributes :id, :name, :friendly_id, :created_at, :active, :participants
  attribute :shared_owner, if: -> { object.shared }

  def shared_owner
    object.user.name
  end
end
