# frozen_string_literal: true

class PermissionsChecker
  def initialize(current_user:, permission_name:, user_id: '', friendly_id: '', record_id: '')
    @current_user = current_user
    @permission_name = permission_name
    @user_id = user_id
    @friendly_id = friendly_id
    @record_id = record_id
  end

  def call
    return true if RolePermission.joins(:permission)
                                 .find_by(role_id: @current_user.role_id, permission: { name: @permission_name })&.value == 'true'

    case @permission_name
    when 'ManageUsers'
      return authorize_manage_user
    when 'ManageRooms'
      return authorize_manage_rooms
    when 'ManageRecordings'
      return authorize_manage_recordings
    end

    false
  end

  private

  def authorize_manage_user
    @current_user.id.to_s == @user_id.to_s
  end

  def authorize_manage_rooms
    @current_user.rooms.find_by(friendly_id: @friendly_id).present?
  end

  def authorize_manage_recordings
    @current_user.recordings.find_by(record_id: @record_id).present?
  end
end
