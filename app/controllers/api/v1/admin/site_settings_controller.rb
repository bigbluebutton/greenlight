# frozen_string_literal: true

module Api
  module V1
    module Admin
      class SiteSettingsController < ApiController
        def index
          site_settings = Setting.joins(:site_settings)
                        .where(site_settings: { provider: 'greenlight' })
                        .pluck(:name, :value)
                        .to_h

          return render_error status: :internal_server_error if site_settings.blank?
          
          render_json data: site_setting
        end

        def update
          return render_error status: :bad_request unless params[:siteSetting] && params[:siteSetting][:value]

          site_setting = SiteSetting.joins(:setting)
                                    .find_by(
                                      provider: 'greenlight',
                                      setting: { name: params[:name] }
                                    )

          return render_error status: :not_found unless site_setting

          return render_error status: :bad_request unless site_setting.update(value: params[:siteSetting][:value].to_s)

          render_json
        end
      end
    end
  end
end
