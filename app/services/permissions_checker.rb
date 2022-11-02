# frozen_string_literal: true

class PermissionsChecker
  def initialize(current_user:, permission_names:, user_id:, friendly_id:, record_id:)
    @current_user = current_user
    @permission_names = permission_names
    @user_id = user_id
    @friendly_id = friendly_id
    @record_id = record_id
  end

  def call
    return true if RolePermission.joins(:permission).exists?(
      role_id: @current_user.role_id,
      permission: { name: @permission_names },
      value: 'true'
    )

    # convert to array if only checking for 1 permission (for simplicity)
    Array(@permission_names).each do |permission|
      case permission
      when 'ManageUsers'
        return true if authorize_manage_user
      when 'ManageRooms'
        return true if authorize_manage_rooms
      when 'SharedRoom'
        return true if authorize_shared_room
      when 'ManageRecordings'
        return true if authorize_manage_recordings
      when 'RoomLimit'
        return true if authorize_room_limit
      end
    end

    false
  end

  private

  def authorize_manage_user
    return false if @user_id.blank?

    @current_user.id.to_s == @user_id.to_s
  end

  def authorize_manage_rooms
    return false if @friendly_id.blank?

    @current_user.rooms.find_by(friendly_id: @friendly_id).present?
  end

  def authorize_shared_room
    return false if @friendly_id.blank?

    @current_user.shared_rooms.exists?(friendly_id: @friendly_id)
  end

  def authorize_manage_recordings
    return false if @record_id.blank?

    @current_user.recordings.find_by(record_id: @record_id).present?
  end

  def authorize_room_limit
    return false if @user_id.blank?

    user = User.find(@user_id)
    # return true if room limit has not been reached
    if RolePermission.joins(:permission).find_by(role_id: user.role_id, permission: { name: 'RoomLimit' }).value.to_i <= user.rooms.count.to_i
      return false
    end

    true
  end
end
