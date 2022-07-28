# frozen_string_literal: true

module Authorizable
  extend ActiveSupport::Concern

  # Unless the request format is explicitly json Rails will mitigate the responsibility to CSR to handle it.
  def ensure_valid_request
    return render 'components/index' if !Rails.env.development? && !valid_api_request?
  end

  # Ensures that the user is logged in
  def ensure_authenticated
    return render_error status: :unauthorized unless current_user
  end

  private

  # Ensures that requests to the API are explicit enough.
  def valid_api_request?
    request.format == :json && request.headers['Accept']&.include?('application/json')
  end
end
