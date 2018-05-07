class SessionsController < ApplicationController

  # GET /login
  def new
  end

  # GET /logout
  def destroy
    logout
  end

  # GET/POST /auth/:provider/callback
  def create
    user = User.from_omniauth(request.env['omniauth.auth'])
    login(user)
  end

  # POST /auth/failure
  def fail

  end
end
