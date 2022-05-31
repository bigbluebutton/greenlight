# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Returns the current signed in User (if any)
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
end
