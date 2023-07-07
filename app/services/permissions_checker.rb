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

# rubocop:disable Metrics/CyclomaticComplexity
class PermissionsChecker
  def initialize(current_user:, permission_names:, current_provider:, user_id: nil, friendly_id: nil, record_id: nil)
    @current_user = current_user
    @permission_names = permission_names
    @user_id = user_id
    @friendly_id = friendly_id
    @record_id = record_id
    @current_provider = current_provider
  end

  # The permission checker checks if:
  # 1. A current_user exists in the context:
  #    1.1. Checks if the current_user is a SuperAdmin and allow it without further checks.
  #    1.2. Ensures that the current_user provider and the target resource provider matches.
  #    1.3. Ensures that the the current_user is active.
  #    1.4. Checks if the current_user is allowed to access a whole class of resources AKA admin (has at least one permission enabled for its role).
  # 2. Checks if the current_user is not an admin but allowed to access that specific target resource.
  def call
    if @current_user
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
    end

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
      when 'PublicRecordings'
        return true if authorize_public_recordings
      end
    end

    false
  end

  private

  # Ensures that the current_user is requesting access to manage its account specifically.
  def authorize_manage_user
    return false if @current_user.blank?
    return false if @user_id.blank?

    @current_user.id.to_s == @user_id.to_s
  end

  # Ensures that the current_user is requesting access to manage one of its rooms specifically.
  def authorize_manage_rooms
    return false if @current_user.blank?
    return false if @friendly_id.blank?

    @current_user.rooms.find_by(friendly_id: @friendly_id).present?
  end

  # Ensures that the current_user is requesting access to manage a shared room specifically.
  def authorize_shared_room
    return false if @current_user.blank?
    return false if @friendly_id.blank? && @record_id.blank?

    @current_user.shared_rooms.exists?(friendly_id: @friendly_id) ||
      @current_user.shared_rooms.exists?(id: Recording.find_by(record_id: @record_id)&.room_id)
  end

  # Ensures that the current_user is requesting access to manage its rooms recordings specifically.
  def authorize_manage_recordings
    return false if @current_user.blank?
    return false if @record_id.blank?

    @current_user.recordings.find_by(record_id: @record_id).present?
  end

  # Ensures that the request is to access and manage a publicly accessible recording.
  def authorize_public_recordings
    return false if @record_id.blank?
    return false if @current_provider.blank?

    recording = Recording.find_by(record_id: @record_id)
    return false unless recording
    return false if recording.user.provider != @current_provider
    return false unless [Recording::VISIBILITIES[:public], Recording::VISIBILITIES[:public_protected]].include? recording.visibility

    true
  end

  # Checks if the target user has reached its role room limit.
  def authorize_room_limit
    return false if @user_id.blank?

    user = User.find(@user_id)
    # return true if room limit has not been reached
    if RolePermission.joins(:permission).find_by(role_id: user.role_id, permission: { name: 'RoomLimit' }).value.to_i <= user.rooms.count.to_i
      return false
    end

    true
  end

  # Checks if the current_user is requsting to access a resource of the same provider.
  def current_provider_check
    return false if @current_user.blank? || @current_user.provider.blank? || @current_provider.blank?

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
# rubocop:enable Metrics/CyclomaticComplexity
