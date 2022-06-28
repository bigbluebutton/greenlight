# frozen_string_literal: true

class RoomSerializer < ActiveModel::Serializer
  attributes :id, :name, :friendly_id, :created_at
  attribute :shared_owner, if: -> { object.shared }

  def created_at
    object.created_at.strftime('%A %B %e, %Y %l:%M%P')
  end

  def shared_owner
    object.user.name
  end
end
