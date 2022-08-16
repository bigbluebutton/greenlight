# frozen_string_literal: true

module Api
  module V1
    class RoomsConfigurationsController < ApiController
      # GET /api/v1/rooms_configurations.json
      # Expects: {}
      # Returns: { data: Array[serializable objects] , errors: Array[String] }
      # Does: Fetches and returns a Hash :name => :value of all rooms configurations.
      def index
        rooms_configs = MeetingOption.joins(:rooms_configurations)
                                     .where(rooms_configurations: { provider: current_provider })
                                     .pluck(:name, :value)
                                     .to_h

        render_data data: rooms_configs, status: :ok
      end
    end
  end
end
