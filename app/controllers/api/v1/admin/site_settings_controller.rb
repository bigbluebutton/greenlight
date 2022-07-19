# frozen_string_literal: true

module Api
  module V1
    module Admin
      class SiteSettingsController < ApiController
        def update
          SiteSetting.find_by(setting_id: params[:settingId]).update(value: params[:settingValue].to_s)

          render_json
        end
      end
    end
  end
end
