# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :find_user, only: [:edit, :update]
  before_action :ensure_unauthenticated, only: [:new, :create]

  # POST /u
  def create
    # Verify that GreenLight is configured to allow user signup.
    return unless Rails.configuration.allow_user_signup

    @user = User.new(user_params)
    @user.provider = "greenlight"

    if @user.save
      login(@user)
    else
      # Handle error on user creation.
      render :new
    end
  end

  # GET /signup
  def new
    if Rails.configuration.allow_user_signup
      @user = User.new
    else
      redirect_to root_path
    end
  end

  # GET /u/:user_uid/edit
  def edit
    if current_user
      redirect_to current_user.room unless @user == current_user
    else
      redirect_to root_path
    end
  end

  # PATCH /u/:user_uid/edit
  def update
    if params[:setting] == "password"
      # Update the users password.
      errors = {}

      if @user.authenticate(user_params[:password])
        # Verify that the new passwords match.
        if user_params[:new_password] == user_params[:password_confirmation]
          @user.password = user_params[:new_password]
        else
          # New passwords don't match.
          errors[:password_confirmation] = "doesn't match"
        end
      else
        # Original password is incorrect, can't update.
        errors[:password] = "is incorrect"
      end

      if errors.empty? && @user.save
        # Notify the use that their account has been updated.
        redirect_to edit_user_path(@user), notice: "Information successfully updated."
      else
        # Append custom errors.
        errors.each { |k, v| @user.errors.add(k, v) }
        render :edit
      end
    elsif @user.update_attributes(user_params)
      redirect_to edit_user_path(@user), notice: "Information successfully updated."
    else
      render :edit
    end
  end

  # GET /u/terms
  def terms
    redirect_to root_path unless current_user

    if params[:accept] == "true"
      current_user.update_attribute(accepted_terms: true)
      redirect_to current_user.main_room
    end
  end

  private

  def find_user
    @user = User.find_by!(uid: params[:user_uid])
  end

  def ensure_unauthenticated
    redirect_to current_user.main_room if current_user
  end

  def user_params
    params.require(:user).permit(:name, :email, :image, :password, :password_confirmation, :new_password, :provider)
  end
end
