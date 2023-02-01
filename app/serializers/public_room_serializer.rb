# frozen_string_literal: true

class PublicRoomSerializer < ApplicationSerializer
  include Avatarable

  attributes :name, :recording_consent, :require_authentication, :viewer_access_code, :moderator_access_code,
             :anyone_join_as_moderator, :friendly_id, :owner_name, :owner_id, :owner_avatar, :shared_user_ids

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

  def anyone_join_as_moderator
    @instance_options[:options][:settings]['glAnyoneJoinAsModerator']
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

  def shared_user_ids
    object.shared_users.pluck(:id)
  end
end
