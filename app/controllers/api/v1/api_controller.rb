# frozen_string_literal: true

module Api
  module V1
    class ApiController < ApplicationController
      include Authorizable

      serialization_scope :view_context
      before_action :ensure_valid_request, :ensure_authenticated

      # For requests that raised an unkown exception.
      # Note: The order of each rescue is important (The highest has the lowest priority).
      rescue_from StandardError do |exception|
        log_exception exception
        render_error errors: [Rails.configuration.custom_error_msgs[:server_error]], status: :internal_server_error
      end

      rescue_from ActionController::ParameterMissing do |exception|
        log_exception exception
        render_error errors: [Rails.configuration.custom_error_msgs[:missing_params]], status: :bad_request
      end

      rescue_from ActiveRecord::RecordNotFound do |exception|
        log_exception exception
        render_error errors: [Rails.configuration.custom_error_msgs[:record_not_found]], status: :not_found
      end

      # TODO: amir - Better Error handling.

      def log_exception(exception)
        logger.error exception.message
        logger.error exception.backtrace.join("\n") # TODO: amir - Revisit this.
      end

      def render_data(status:, serializer: nil, data: {}, meta: {}, options: {})
        # Manually add the data root if passing in a simple (non-serialized) object
        data = { data: } if data.is_a?(Hash) || data.is_a?(String) || data.is_a?(Integer) || [true, false].include?(data)

        args = {
          json: data,
          root: 'data',
          status:,
          meta:,
          options:
        }

        if serializer.present? && (data.is_a?(Array) || data.is_a?(ActiveRecord::Relation))
          args[:each_serializer] = serializer
        else
          args[:serializer] = serializer
        end

        render args
      end

      def render_error(errors: [], status: :bad_request)
        render json: {
          errors:
        }, status:
      end

      def config_sorting(allowed_columns: [])
        return {} unless params.key?(:sort)

        allowed_directions = %w[ASC DESC]

        sort_column = params[:sort][:column]
        sort_direction = params[:sort][:direction]

        return {} unless allowed_columns.include?(sort_column) && allowed_directions.include?(sort_direction)

        { sort_column => sort_direction }
      end
    end
  end
end
