class UsersController < ApplicationController
  before_action :set_user, only: [:edit, :update]

  # GET /users/1/edit
  def edit
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    if @user.update(user_params)
      redirect_to controller: 'landing', action: 'index', id: @user.username, resource: 'rooms'
    else
      @error = @user.errors.first[1] rescue nil
      render :edit
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
      if @user.username
        render 'errors/error'
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:username)
    end
end
