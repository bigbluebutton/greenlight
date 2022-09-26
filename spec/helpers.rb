# frozen_string_literal: true

module Helpers
  def sign_in_user(user)
    session[:session_token] = user.session_token
  end
end
