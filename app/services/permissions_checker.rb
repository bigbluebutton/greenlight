# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with Greenlight; if not, see <http://www.gnu.org/licenses/>.

# frozen_string_literal: true

class PermissionsChecker
  def initialize(current_user:, permission_names:, current_provider:, user_id: nil, friendly_id: nil, record_id: nil)
    @current_user = current_user
    @permission_names = permission_names
    @user_id = user_id
    @friendly_id = friendly_id
    @record_id = record_id
    @current_provider = current_provider
  end

  def call
    # check to see if current_user has SuperAdmin role
    return true if @current_user.role == Role.find_by(name: 'SuperAdmin', provider: 'bn')

    # checking if user is trying to access users/rooms/recordings from different provider
    return false unless current_provider_check
    # Make sure the user is not banned or pending
    return false unless @current_user.active?

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
    return false if @friendly_id.blank? && @record_id.blank?

    @current_user.shared_rooms.exists?(friendly_id: @friendly_id) ||
      @current_user.shared_rooms.exists?(id: Recording.find_by(record_id: @record_id)&.room_id)
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

  def current_provider_check
    # check to see if current user is trying to access another provider
    return false if @current_user.provider != @current_provider

    # check to see if current_user is trying to access a user from another provider
    return false if @user_id.present? && (@current_user.provider != User.find(@user_id.to_s).provider)

    # check to see if current_user is trying to access a room from another provider
    return false if @friendly_id.present? && (@current_user.provider != Room.find_by(friendly_id: @friendly_id.to_s).user.provider)

    # check to see if current_user is trying to access a recording from another provider
    return false if @record_id.present? && (@current_user.provider != Recording.find_by(record_id: @record_id.to_s).user.provider)

    true
  end
end
