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

        # GET /api/v1/admin/site_settings/:name.json
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

          return render_error status: :bad_request unless update

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
