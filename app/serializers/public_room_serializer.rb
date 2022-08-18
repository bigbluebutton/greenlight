# frozen_string_literal: true

class PublicRoomSerializer < ApplicationSerializer
  attributes :name, :viewer_access_code, :moderator_access_code

  def viewer_access_code
    # TODO: Use `RoomSettingsGetter` and remove deprecation.
    object.viewer_access_code.present?
  end

  def moderator_access_code
    # TODO: Use `RoomSettingsGetter` and remove deprecation.
    object.moderator_access_code.present?
  end
end
