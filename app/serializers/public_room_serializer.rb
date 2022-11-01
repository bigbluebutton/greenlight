# frozen_string_literal: true

class PublicRoomSerializer < ApplicationSerializer
  include Avatarable

  attributes :name, :recording_consent, :require_authentication, :viewer_access_code, :moderator_access_code,
             :friendly_id, :owner_name, :owner_id, :owner_avatar

  def recording_consent
    @instance_options[:options][:settings]['record']
  end

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

  def owner_id
    object.user.id
  end

  def owner_avatar
    user_avatar(object.user)
  end
end
