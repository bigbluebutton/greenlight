# frozen_string_literal: true

module Api
  module V1
    class SiteSettingsController < ApiController
      def index
        site_setting_data = {}
        site_settings = SiteSetting.joins(:setting).select(:id, :name, :value)

        site_settings.each do |setting|
          site_setting_data[setting.name] = { value: setting.value, id: setting.id }
        end

        render_json data: site_setting_data
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
