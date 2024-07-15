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

module Api
  module V1
    class ServerTagsController < ApiController
      # GET /api/v1/server_tags.json
      # Returns a list of all allowed tags for the current user
      def index
        tags = Rails.configuration.server_tag_names
        tag_roles = Rails.configuration.server_tag_roles
        tags.delete_if { |tag, _| tag_roles.key?(tag) && tag_roles[tag].exclude?(current_user.role_id) }

        render_data data: tags, status: :ok
      end
    end
  end
end
