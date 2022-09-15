# frozen_string_literal: true

module Helpers
  def sign_in_user(user)
    session[:user_id] = user.id
    session[:session_token] = user.session_token
    session[:session_expiry] = user.session_expiry
  end
end
