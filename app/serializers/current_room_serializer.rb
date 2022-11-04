# frozen_string_literal: true

class CurrentRoomSerializer < ApplicationSerializer
  include Presentable

  attributes :id, :name, :presentation_name, :thumbnail, :online, :participants, :shared, :owner_name

  attribute :last_session, if: -> { object.last_session }

  def presentation_name
    presentation_file_name(object)
  end

  def thumbnail
    presentation_thumbnail(object)
  end

  def last_session
    object.last_session.strftime('%B %e, %Y %l:%M%P')
  end

  def owner_name
    object.user.name
  end
end
