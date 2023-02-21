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
