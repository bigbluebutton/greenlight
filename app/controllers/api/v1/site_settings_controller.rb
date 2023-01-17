# frozen_string_literal: true

module Api
  module V1
    class SiteSettingsController < ApiController
      skip_before_action :ensure_authenticated, only: :index
      FORBIDDEN_SETTINGS = %w[RoleMapping ResyncOnLogin DefaultRole].freeze # Should not be accessible to the frontend

      # GET /api/v1/site_settings
      # Returns the values of 1 or multiple site_settings that are not forbidden to access
      def index
        settings = {}
        return render_error status: :forbidden if forbidden_settings(params[:names])

        if params[:names].is_a?(Array)
          params[:names].each do |name|
            settings[name] = SettingGetter.new(setting_name: name, provider: current_provider).call
          end
        else
          # return the value directly
          settings = SettingGetter.new(setting_name: params[:names], provider: current_provider).call
        end

        render_data data: settings, status: :ok
      end

      private

      # Prevents front-end from accessing sensitive site settings
      def forbidden_settings(names)
        # Check if the 2 arrays have any values in common
        !(Array(names) & FORBIDDEN_SETTINGS).empty?
      end
    end
  end
end
