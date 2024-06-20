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

module Authorizable
  extend ActiveSupport::Concern

  # Unless the request format is explicitly json Rails will mitigate the responsibility to CSR to handle it.
  def ensure_valid_request
    render 'components/index' if !Rails.env.development? && !valid_api_request?
  end

  # Ensures that the user is logged in
  def ensure_authenticated
    render_error status: :unauthorized unless current_user
  end

  # Ensures that the user is NOT logged in
  def ensure_unauthenticated
    render_error status: :unauthorized if current_user
  end

  # PermissionsChecker service will return a true or false depending on whether the current_user's role has the provided permission_name
  def ensure_authorized(permission_names, user_id: nil, friendly_id: nil, record_id: nil)
    render_error status: :forbidden unless PermissionsChecker.new(
      current_user:,
      permission_names:,
      user_id:,
      friendly_id:,
      record_id:,
      current_provider:
    ).call
  end

  def ensure_super_admin
    render_error status: :forbidden unless current_user.super_admin?
  end

  private

  # Ensures that requests to the API are explicit enough.
  def valid_api_request?
    request.format == :json && request.headers['Accept']&.include?('application/json')
  end
end
