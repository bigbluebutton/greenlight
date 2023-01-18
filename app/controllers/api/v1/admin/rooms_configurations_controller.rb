# frozen_string_literal: true

module Api
  module V1
    module Admin
      class RoomsConfigurationsController < ApiController
        before_action do
          ensure_authorized('ManageSiteSettings')
        end

        # PUT /api/v1/admin/rooms_configurations/:name.json
        # Update a rooms configuration value
        def update
          return render_error status: :bad_request unless params[:RoomsConfig] && params[:RoomsConfig][:value]

          rooms_config = RoomsConfiguration.joins(:meeting_option)
                                           .find_by(
                                             provider: current_provider,
                                             meeting_option: { name: params[:name] }
                                           )

          return render_error status: :not_found unless rooms_config

          return render_error status: :bad_request unless rooms_config.update(value: params[:RoomsConfig][:value])

          render_data status: :ok
        end
      end
    end
  end
end
