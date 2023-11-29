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
      class SiteSettingsController < ApiController
        before_action do
          ensure_authorized('ManageSiteSettings')
        end

        # GET /api/v1/admin/site_settings.json
        # Returns a list of all site settings
        def index
          site_settings = Setting.joins(:site_settings)
                                 .where(name: params[:names], site_settings: { provider: current_provider })
                                 .pluck(:name, :value)
                                 .to_h

          render_data data: site_settings, status: :ok
        end

        # PATCH /api/v1/admin/site_settings/:name.json
        # Updates the value of the specified Site Setting
        def update
          site_setting = SiteSetting.joins(:setting)
                                    .find_by(
                                      provider: current_provider,
                                      setting: { name: params[:name] }
                                    )
          return render_error status: :not_found unless site_setting

          update = if params[:name] == 'BrandingImage'
                     site_setting.image.attach params[:site_setting][:value]
                   else
                     site_setting.update(value: params[:site_setting][:value].to_s)
                   end

          unless update
            return render_error status: :bad_request,
                                errors: Rails.configuration.custom_error_msgs[:record_invalid]
          end

          render_data status: :ok
        end

        # DELETE /api/v1/admin/site_settings/purge_branding_image.json
        # Removes the custom branding image back to bbb default
        def purge_branding_image
          site_setting = SiteSetting.joins(:setting)
                                    .find_by(
                                      provider: current_provider,
                                      setting: { name: 'BrandingImage' }
                                    )
          site_setting.image.purge

          render_data status: :ok
        end
      end
    end
  end
end
