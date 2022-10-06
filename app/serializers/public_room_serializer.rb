# frozen_string_literal: true

class PublicRoomSerializer < ApplicationSerializer
  include Avatarable

  attributes :name, :require_authentication, :viewer_access_code, :moderator_access_code, :owner_name, :owner_avatar

  def require_authentication
    @instance_options[:options][:settings]['glRequireAuthentication']
  end

  def viewer_access_code
    @instance_options[:options][:settings]['glViewerAccessCode']
  end

  def moderator_access_code
    @instance_options[:options][:settings]['glModeratorAccessCode']
  end

  def owner_name
    object.user.name
  end

  def owner_avatar
    user_avatar(object.user)
  end
end
