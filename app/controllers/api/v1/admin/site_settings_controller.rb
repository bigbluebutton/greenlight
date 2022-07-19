# frozen_string_literal: true

module Api
  module V1
    module Admin
      class SiteSettingsController < ApiController
        def update
          SiteSetting
            .joins(:setting)
            .where(provider: 'greenlight')
            .where(setting: { name: params[:settingName] })
            .update(value: params[:settingValue].to_s)
          render_json
        end
      end
    end
  end
end
