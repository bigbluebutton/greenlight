# frozen_string_literal: true

module ClientRoutable
  extend ActiveSupport::Concern

  # Generates a client side activate account url.
  def activate_account_url(token)
    "#{root_url}activate_account/#{token}"
  end

  # Generates a client side reset password url.
  def reset_password_url(token)
    "#{root_url}reset_password/#{token}"
  end
end
