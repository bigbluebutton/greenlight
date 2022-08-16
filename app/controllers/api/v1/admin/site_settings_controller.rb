# frozen_string_literal: true

module Api
  module V1
    module Admin
      class SiteSettingsController < ApiController
        before_action do
          ensure_authorized('ManageSiteSettings')
        end
        def index
          site_settings = Setting.joins(:site_settings)
                                 .where(site_settings: { provider: current_provider })
                                 .pluck(:name, :value)
                                 .to_h

          render_data data: site_settings, status: :ok
        end

        def update
          site_setting = SiteSetting.joins(:setting)
                                    .find_by(
                                      provider: current_provider,
                                      setting: { name: params[:name] }
                                    )
          return render_error status: :not_found unless site_setting

          update = if params[:name] == 'BrandingImage'
                     site_setting.image.attach params[:site_setting][:value]
                     site_setting.update(value: site_setting.image.blob.filename.to_s)
                   else
                     site_setting.update(value: params[:site_setting][:value].to_s)
                   end

          return render_error status: :bad_request unless update

          render_data status: :ok
        end

        def destroy
          site_setting = SiteSetting.joins(:setting)
                                    .find_by(
                                      provider: current_provider,
                                      setting: { name: params[:name] }
                                    )

          return render_error status: :not_found unless site_setting

          site_setting.image.purge if params[:name] == 'BrandingImage'

          if site_setting.update(value: '')
            render_data status: :ok
          else
            render_error status: :bad_request
          end
        end
      end
    end
  end
end
