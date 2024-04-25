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

class CurrentUserSerializer < UserSerializer
  attributes :signed_in, :permissions, :status, :external_account, :super_admin, :allowed_tags

  def signed_in
    true
  end

  def external_account
    object.external_id?
  end

  def permissions
    RolePermission.joins(:permission)
                  .where(role_id: object.role_id)
                  .pluck(:name, :value)
                  .to_h
  end

  def super_admin
    object.super_admin?
  end

  def allowed_tags
    tags = []
    Rails.configuration.server_tag_names.each do |tag, _|
      if Rails.configuration.server_tag_roles.key?(tag)
        tags.push(tag) if Rails.configuration.server_tag_roles[tag].include?(object.role_id)
      else
        tags.push(tag)
      end
    end
    tags.presence
  end
end
