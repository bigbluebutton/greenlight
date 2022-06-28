# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApiController
      skip_before_action :verify_authenticity_token # TODO: amir - Revisit this.
      # POST /api/v1/users.json
      # Expects: { user: { :name, :email, :password, :password_confirmation } }
      # Returns: { data: Array[serializable objects] , errors: Array[String] }
      # Does: Creates and saves a new user record in the database with the provided parameters.

      def create
        # TODO: amir - ensure accessibility for unauthenticated requests only.
        params[:user][:language] = I18n.default_locale if params[:user][:language].blank?

        user = User.new({
          provider: 'greenlight',
          role: Role.find_by(name: 'User') # TODO: - Ahmad: Move to service
        }.merge(user_params)) # TMP fix for presence validation of :provider

        # TODO: Add proper error logging for non-verified token hcaptcha
        return render_json errors: user.errors.to_a, status: :bad_request if hcaptcha_enabled? && !verify_hcaptcha(response: params[:token])

        if user.save
          session[:user_id] = user.id
          token = user.generate_activation_token!
          render_json data: { token: }, status: :created # TODO: enable activation email sending.
        else
          # TODO: amir - Improve logging.
          render_json errors: user.errors.to_a, status: :bad_request
        end
      end

      # TODO: Add a before_action callback to update,destory and purge_avatar calling a find_user.
      def update
        user = User.find(params[:id])
        if user.update(user_params)
          render_json status: :ok
        else
          render_json errors: user.errors.to_a, status: :bad_request
        end
      end

      def destroy
        user = User.find(params[:id])
        if user.destroy
          render_json status: :ok
        else
          render_json errors: user.errors.to_a, status: :bad_request
        end
      end

      def purge_avatar
        user = User.find(params[:id])
        user.avatar.purge

        render_json status: :ok
      end

      # POST /api/v1/users/change_password.json
      # Expects: { user: { :old, :new } }
      # Returns: { data: Array[serializable objects] , errors: Array[String] }
      # Does: Validates and change the user password.

      def change_password
        return render_json status: :unauthorized unless current_user # TODO: generalise this.

        return render_json status: :forbidden if current_user.external_id?

        old_password = change_password_params[:old_password]
        new_password = change_password_params[:new_password]

        return render_json status: :bad_request if new_password.blank? || old_password.blank?

        return render_json status: :bad_request unless current_user.authenticate old_password

        current_user.update! password: new_password
        render_json
      end

      private

      def user_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation, :avatar, :language)
      end

      def change_password_params
        params.require(:user).permit(:old_password, :new_password)
      end
    end
  end
end
