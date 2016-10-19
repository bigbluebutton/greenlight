class SessionsController < ApplicationController
  def create
    @user = User.from_omniauth(request.env['omniauth.auth'])
    if @user.persisted?
      session[:user_id] = @user.id
      redirect_to controller: 'landing', action: 'room', id: @user.username
    else
      @user.save!
      session[:user_id] = @user.id
      redirect_to controller: 'users', action: 'edit', id: @user.id
    end
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
