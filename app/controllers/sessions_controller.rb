class SessionsController < ApplicationController
  def create
    @user = User.from_omniauth(request.env['omniauth.auth'])
    session[:user_id] = @user.id
    redirect_to @user.room_url
  rescue => e
    logger.error "Error authenticating via omniauth: #{e}"
    redirect_to root_path
  end

  def destroy
    if current_user
      session.delete(:user_id)
    end
    redirect_to root_path
  end
end
