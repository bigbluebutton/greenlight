# frozen_string_literal: true

class PublicRoomSerializer < ApplicationSerializer
  attributes :name, :require_authentication, :viewer_access_code, :moderator_access_code

  def require_authentication
    @instance_options[:options][:settings]['glRequireAuthentication']
  end

  def viewer_access_code
    @instance_options[:options][:settings]['glViewerAccessCode']
  end

  def moderator_access_code
    @instance_options[:options][:settings]['glModeratorAccessCode']
  end
end
