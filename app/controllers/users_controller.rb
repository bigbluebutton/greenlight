class UsersController < ApplicationController

  before_action :find_user, only: [:edit, :update]
  before_action :ensure_unauthenticated, only: [:new, :create]

  # POST /users
  def create
    user = User.new(user_params)
    user.provider = "greenlight"

    if user.save
     login(user)
    else
      # Handle error on user creation.

    end
  end

  # GET /signup
  def new 
    @user = User.new
  end

  # GET /users/:user_uid/edit
  def edit
    if current_user
      redirect_to current_user.room unless @user == current_user
    else
      redirect_to root_path
    end
  end

  # PATCH /users/:user_uid
  def update
    # Update account information if passed.
    @user.name = user_params[:name] if user_params[:name]
    @user.email = user_params[:email] if user_params[:email]

    # Verify that the provided password is correct.
    if user_params[:password] && @user.authenticate(user_params[:password])
      # Verify that the new passwords match.
      if user_params[:new_password] == user_params[:password_confirmation]
        @user.password = user_params[:new_password]
      else
        # New passwords don't match.

      end
    else
      # Original password is incorrect, can't update.

    end

    if @user.save
      # Notify the use that their account has been updated.
      redirect_to edit_user_path(@user), notice: "Information successfully updated."
    else
      # Handle validation errors.
      render :edit
    end
  end
  
  private

  def find_user
    @user = User.find_by(uid: params[:user_uid])

    unless @user
      # Handle user does not exist.

    end
  end

  def ensure_unauthenticated
    redirect_to current_user.main_room if current_user
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :new_password, :provider)
  end
end
