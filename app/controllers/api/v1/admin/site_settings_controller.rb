# frozen_string_literal: true

module Api
  module V1
    module Admin
      class SiteSettingsController < ApiController
        def index
          data = Setting.joins(:site_settings)
                        .where(site_settings: { provider: 'greenlight' })
                        .pluck(:name, :value)
                        .to_h

          render_json data:
        end

        def update
          SiteSetting
            .joins(:setting)
            .where(provider: 'greenlight')
            .where(setting: { name: params[:name] })
            .update(value: params[:value].to_s)
          render_json
        end
      end
    end
  end
end
