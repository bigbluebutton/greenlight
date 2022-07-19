# frozen_string_literal: true

module Api
  module V1
    class SiteSettingsController < ApiController
      def index
        data = Setting.joins(:site_settings)
                      .where(site_settings: { provider: 'greenlight' })
                      .pluck(:name, :value)
                      .to_h

        render_json data:
      end

      # GET /api/v1/site_settings/:name
      def show
        render_data data: SettingGetter.new(setting_name: params[:name], provider: 'greenlight').call, status: :ok # TODO: - ahmad: fix provider
      end

      def update
        SiteSetting.find_by(setting_id: params[:settingId]).update(value: params[:settingValue].to_s)

        render_json
      end
    end
  end
end
