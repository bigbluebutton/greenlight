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
    module Admin
      class InvitationsController < ApiController
        before_action do
          ensure_authorized('ManageUsers')
        end

        # GET /api/v1/admin/invitations
        # Returns a list of all invitations that have not been "redeemed/used"
        def index
          sort_config = config_sorting(allowed_columns: %w[email])

          invitations = Invitation.where(provider: current_provider)&.order(sort_config, updated_at: :desc)&.search(params[:search])
          pagy, invitations = pagy(invitations)

          render_data data: invitations, meta: pagy_metadata(pagy), status: :ok
        end

        # POST /api/v1/admin/invitations
        # Creates an invitation for the specified emails (comma separated) and sends them an email
        def create
          params[:invitations][:emails].split(',').each do |email|
            invitation = Invitation.find_or_initialize_by(email: email.downcase, provider: current_provider).tap do |i|
              i.updated_at = Time.zone.now
              i.save!
            end

            UserMailer.with(
              email:,
              name: current_user.name,
              signup_url: root_url(inviteToken: invitation.token),
              base_url: request.base_url,
              provider: current_provider
            ).invitation_email.deliver_later
          rescue StandardError => e
            logger.error "Failed to send invitation to #{email} - #{e}"
          end

          render_data status: :ok
        rescue StandardError => e
          logger.error "Failed to send invitations to #{params[:invitations][:emails]} - #{e}"
          render_error status: :bad_request
        end

        def destroy
          invitation = Invitation.find(params[:id])
          invitation.destroy
          render_data status: :ok
        rescue StandardError => e
          logger.error "Failed to revoke invite, error: #{e.message}"
          render_error status: :bad_request
        end
      end
    end
  end
end
