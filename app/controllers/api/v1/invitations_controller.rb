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
    class InvitationsController < ApiController
      skip_before_action :ensure_authenticated, only: %i[show]

      # GET /api/v1/invitations/:token
      # Returns the invitation details for the given token (public endpoint for signup pre-fill)
      def show
        invitation = Invitation.find_by(token: params[:token], provider: current_provider)

        if invitation && invitation.updated_at > Invitation::INVITATION_VALIDITY_PERIOD.ago
          render_data data: invitation, serializer: InvitationSerializer, status: :ok
        else
          render_error status: :not_found
        end
      end
    end
  end
end
