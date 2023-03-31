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

module ClientRoutable
  extend ActiveSupport::Concern
  include Rails.application.routes.url_helpers

  # Generates a client side activate account URL.
  def client_activate_account_url(token:, **opts)
    client_url_for(path: "activate_account/#{token}", **opts)
  end

  # Generates a client side reset password URL.
  def client_reset_password_url(token:, **opts)
    client_url_for(path: "reset_password/#{token}", **opts)
  end

  # Generates a client side room join URL.
  def client_room_join_url(friendly_id:, **opts)
    client_url_for(path: "rooms/#{friendly_id}/join", **opts)
  end

  # Generates a client side invite URL.
  def client_invitation_url(**opts)
    client_url_for(**opts)
  end

  private

  def client_url_for(path: nil, **opts)
    "#{root_url(**opts.compact)}#{path}"
  end
end
