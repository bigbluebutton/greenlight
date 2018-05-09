class SessionsController < ApplicationController

  # GET /login
  def new
  end

  # GET /logout
  def destroy
    logout if current_user
  end

  # POST /login
  def create
    user = User.find_by(email: session_params[:email])
    if user && user.authenticate(session_params[:password])
      login(user)
    else
      # Login unsuccessful, display error message.
      
      render :new
    end
  end

  # GET/POST /auth/:provider/callback
  def omniauth_session
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
