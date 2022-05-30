# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action do
    # Unless the request format is explicitly json Rails will mitigate the responsability to CSR to handle it.
    # render 'components/index' unless valid_api_request?
    # TODO - Ahmad: Come up with a better way to do this
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

  # Returns the current signed in User (if any)
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def render_json(data: {}, errors: [], status: :ok, include: nil)
    render json: {
      data:,
      errors:
    }, status:, include:
  end

  private

  # Ensures that requests to the API are explicit enough.
  def valid_api_request?
    request.format == :json && request.headers['Accept']&.include?('application/json')
  end
end
