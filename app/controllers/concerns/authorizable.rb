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

  # PermissionsChecker service will return a true or false depending on whether the current_user's role has the provided permission_name
  def ensure_authorized(permission_names, user_id: nil, friendly_id: nil, record_id: nil)
    # TODO: - should this return a status: :not_found instead of :unauthorized if the user doesn't have the permission AND the param doesn't exists?

    return render_error status: :forbidden unless PermissionsChecker.new(
      current_user:,
      permission_names:,
      user_id:,
      friendly_id:,
      record_id:
    ).call
  end

  private

  # Ensures that requests to the API are explicit enough.
  def valid_api_request?
    request.format == :json && request.headers['Accept']&.include?('application/json')
  end
end
