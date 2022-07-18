# frozen_string_literal: true

module Api
  module V1
    class SiteSettingsController < ApiController
      # GET /api/v1/site_settings.json
      # Expects: {}
      # Returns: { data: Array[serializable objects] , errors: Array[String] }
      # Does: Fetches and returns a Hash :name => :value of all site settings.
      def index
        site_settings = Setting.joins(:site_settings)
                               .where(site_settings: { provider: 'greenlight' })
                               .pluck(:name, :value)
                               .to_h

        return render_error status: :internal_server_error if site_settings.blank?

        # RoleMapping encapsulates a list of rules in a json string, so it needs to be parsed before responding.
        site_settings['RoleMapping'] = JSON.parse(site_settings['RoleMapping']) if site_settings.key?('RoleMapping')

        render_json data: site_settings
      end

      # GET /api/v1/site_settings/:name
      def show
        render_json data: SettingGetter.new(setting_name: params[:name], provider: 'greenlight').call # TODO: - ahmad: fix provider
      end
    end
  end
end
