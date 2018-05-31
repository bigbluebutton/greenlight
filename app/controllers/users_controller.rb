class UsersController < ApplicationController

  # GET /signup
  def new
    @user = User.new
  end

  # POST /signup
  def create
    user = User.new(user_params)
    user.provider = "greenlight"

    if user.save
     login(user)
    else

    end
  end

  # GET /settings
  def settings
    redirect_to root_path unless current_user
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
