# frozen_string_literal: true

class SessionsController < ApplicationController

  LOGIN_FAILED = "Login failed due to invalid credentials. Are you sure you typed them correctly?"

  # GET /users/login
  def new
  end

  # GET /users/logout
  def destroy
    logout
    redirect_to root_path
  end

  # POST /users/login
  def create
    user = User.find_by(email: session_params[:email])
    if user&.authenticate(session_params[:password])
      login(user)
    else
      redirect_to root_path, notice: LOGIN_FAILED
    end
  end

  # POST /launch
  def launch
    # This will recieve a encoded POST from a launcher that
    # contains the provider, and all user information. The
    # launcher is what does the authentication, so we know
    # that the user is who they say they are. We just need
    # to use our secret to decode it and then log them in
    # to GreenLight (or sign them up).

    # User.from_launch()
  end

  # GET/POST /auth/:provider/callback
  def omniauth
    user = User.from_omniauth(request.env['omniauth.auth'])
    login(user)
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
