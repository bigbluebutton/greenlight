# frozen_string_literal: true

module Api
  module V1
    class ApiController < ApplicationController
      serialization_scope :view_context

      before_action do
        # Unless the request format is explicitly json Rails will mitigate the responsability to CSR to handle it.
        render 'components/index' if !Rails.env.development? && !valid_api_request?
      end

      # For requests that raised an unkown exception.
      # Note: The order of each rescue is important (The highest has the lowest priority).
      rescue_from StandardError do |exception|
        log_exception exception
        render_json errors: [Rails.configuration.custom_error_msgs[:server_error]], status: :internal_server_error
      end

      rescue_from ActionController::ParameterMissing do |exception|
        log_exception exception
        render_json errors: [Rails.configuration.custom_error_msgs[:missing_params]], status: :bad_request
      end

      rescue_from ActiveRecord::RecordNotFound do |exception|
        log_exception exception
        render_json errors: [Rails.configuration.custom_error_msgs[:record_not_found]], status: :not_found
      end

      # TODO: amir - Better Error handling.

      def log_exception(exception)
        logger.error exception.message
        logger.error exception.backtrace.join("\n") # TODO: amir - Revisit this.
      end

      def render_data(data: {}, status: :ok, include: nil, serializer: nil, options: {})
        render json: data, status:, include:, root: 'data', serializer:, options:
      end

      def render_error(errors: [], status: :bad_request)
        render json: {
          errors:
        }, status:
      end

      def render_json(data: {}, errors: [], status: :ok, include: nil)
        render json: {
          data:,
          errors:
        }, status:, include:
      end

      def config_sorting(allowed_columns: [])
        return {} unless params.key?(:sort)

        allowed_directions = %w[ASC DESC]

        sort_column = params[:sort][:column]
        sort_direction = params[:sort][:direction]

        return {} unless allowed_columns.include?(sort_column) && allowed_directions.include?(sort_direction)

        { sort_column => sort_direction }
      end

      private

      # Ensures that requests to the API are explicit enough.
      def valid_api_request?
        request.format == :json && request.headers['Accept']&.include?('application/json')
      end
    end
  end
end
