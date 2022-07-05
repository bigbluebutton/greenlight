# frozen_string_literal: true

class CurrentRoomSerializer < ApplicationSerializer
  include Presentable
  include Avatarable

  attributes :id, :name, :presentation_name, :thumbnail, :viewer_access_code, :moderator_access_code, :created_at

  attribute :owner_name, if: -> { @instance_options[:options][:include_owner] }
  attribute :owner_avatar, if: -> { @instance_options[:options][:include_owner] }

  def presentation_name
    presentation_file_name(object)
  end

  def thumbnail
    presentation_thumbnail(object)
  end

  def viewer_access_code
    object.viewer_access_code.present?
  end

  def moderator_access_code
    object.moderator_access_code.present?
  end

  def owner_name
    object.user.name
  end

  def owner_avatar
    user_avatar(object.user)
  end
end
