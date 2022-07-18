# frozen_string_literal: true

module Api
  module V1
    module Admin
      class SiteSettingsController < ApiController
        # PUT /api/v1/admin/site_settings/:name.json
        # Expects: { site_setting: { :value } }
        # Returns: { data: Array[serializable objects] , errors: Array[String] }
        # Does: Update a site setting :value with its json representation.

        def update
          return render_error status: :bad_request unless params[:site_setting] && params[:site_setting][:value]

          site_setting = SiteSetting.joins(:setting)
                                    .find_by(
                                      provider: 'greenlight',
                                      setting: { name: params[:name] }
                                    )

          return render_error status: :not_found unless site_setting

          # Some site settings :value will hold a stringified json representation.
          value = if params[:name] == 'RoleMapping'
                    params[:site_setting][:value].to_json
                  else
                    params[:site_setting][:value]
                  end

          return render_error status: :bad_request unless site_setting.update(value:)

          render_json
        end
      end
    end
  end
end
