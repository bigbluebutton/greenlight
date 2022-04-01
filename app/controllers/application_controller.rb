# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session # TODO: amir - Enable CSRF with a new made strategy.

  before_action do
    # Unless the request format is explicitly json Rails will mitigate the responsability to CSR to handle it.
    render 'components/index' unless valid_api_request?
  end

  # For requests omitting required params.
  rescue_from ActionController::ParameterMissing do |exception|
    log_exception exception
    render json: {
      data: [],
      errors: [Rails.configuration.custom_error_msgs[:missing_params]]
    }, status: :bad_request
  end

  # TODO: amir - Better Error handling.

  def log_exception(exception)
    logger.error exception.message
    logger.error exception.backtrace.join("\n")
  end

  # Returns the current signed in User (if any)
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  private

  # Ensures that requests to the API are explicit enough.
  def valid_api_request?
    request.format == :json && request.headers['Accept'].include?('application/json')
  end
end
