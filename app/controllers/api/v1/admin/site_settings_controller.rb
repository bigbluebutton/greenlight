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

          render_data data: site_settings, status: :ok
        end

        def update
          site_setting = SiteSetting.joins(:setting)
                                    .find_by(
                                      provider: 'greenlight',
                                      setting: { name: params[:name] }
                                    )
          return render_error status: :not_found unless site_setting

          return render_error status: :bad_request unless site_setting.update(value: params[:siteSetting][:value].to_s)

          render_data status: :ok
        end
      end
    end
  end
end
