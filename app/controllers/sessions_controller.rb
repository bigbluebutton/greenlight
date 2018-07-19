# frozen_string_literal: true

class SessionsController < ApplicationController
  # GET /users/logout
  def destroy
    logout
    redirect_to root_path
  end

  # POST /users/login
  def create
    user = User.find_by(email: session_params[:email])
    if user.try(:authenticate, session_params[:password])
      login(user)
    else
      redirect_to root_path, notice: I18n.t("login_failed")
    end
  end

  # GET/POST /auth/:provider/callback
  def omniauth
    user = User.from_omniauth(request.env['omniauth.auth'])
    login(user)
  rescue => e
    logger.error "Error authenticating via omniauth: #{e}"
    redirect_to root_path
  end

  # POST /auth/failure
  def fail
    redirect_to root_path
  end

  private

  def session_params
    params.require(:session).permit(:email, :password)
  end
end
