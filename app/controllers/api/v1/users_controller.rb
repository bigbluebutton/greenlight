# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApiController
      include ClientRoutable

      skip_before_action :ensure_authenticated, only: %i[create]

      before_action except: %i[create change_password] do
        ensure_authorized('ManageUsers', user_id: params[:id])
      end

      # GET /api/v1/users/:id.json
      # Returns the details of a specific user
      def show
        user = User.find(params[:id])

        render_data data: user, status: :ok
      end

      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      # POST /api/v1/users.json
      # Creates and saves a new user record in the database with the provided parameters
      def create
        # Check if this is an admin creating a user
        admin_create = current_user && PermissionsChecker.new(current_user:, permission_names: 'ManageUsers', current_provider:).call

        # Users created by a user will have the creator language by default with a fallback to the server configured default_locale.
        user_params[:language] = current_user&.language || I18n.default_locale if user_params[:language].blank?

        registration_method = SettingGetter.new(setting_name: 'RegistrationMethod', provider: current_provider).call

        if registration_method == SiteSetting::REGISTRATION_METHODS[:invite] && !valid_invite_token && !admin_create
          return render_error errors: Rails.configuration.custom_error_msgs[:invite_token_invalid]
        end

        user = UserCreator.new(user_params: user_params.except(:invite_token), provider: current_provider, role: default_role).call

        # TODO: Add proper error logging for non-verified token hcaptcha
        if !admin_create && hcaptcha_enabled? && !verify_hcaptcha(response: params[:token])
          return render_error errors: Rails.configuration.custom_error_msgs[:hcaptcha_invalid]
        end

        # Set to pending if registration method is approval
        user.pending! if !admin_create && registration_method == SiteSetting::REGISTRATION_METHODS[:approval]

        if user.save
          user.generate_session_token!
          session[:session_token] = user.session_token unless current_user # if this is NOT an admin creating a user

          token = user.generate_activation_token!
          UserMailer.with(user:, expires_in: User::ACTIVATION_TOKEN_VALIDITY_PERIOD.from_now,
                          activation_url: activate_account_url(token)).activate_account_email.deliver_later

          create_default_room(user)

          render_data data: current_user, serializer: CurrentUserSerializer, status: :created
        elsif user.errors.size == 1 && user.errors.of_kind?(:email, :taken)
          render_error errors: Rails.configuration.custom_error_msgs[:email_exists], status: :bad_request
        else
          render_error errors: Rails.configuration.custom_error_msgs[:record_invalid], status: :bad_request
        end
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      # PATCH /api/v1/users/:id.json
      # Updates the values of a user
      def update
        user = User.find(params[:id])
        # user is updating themselves
        if current_user.id == params[:id] && !PermissionsChecker.new(permission_names: 'ManageUsers', current_user:, current_provider:).call
          params[:user].delete(:role_id)
        end

        if user.update(user_params)
          create_default_room(user)
          render_data  status: :ok
        else
          render_error errors: Rails.configuration.custom_error_msgs[:record_invalid]
        end
      end

      # DELETE /api/v1/users/:id.json
      # Deletes a user
      def destroy
        user = User.find(params[:id])
        if user.destroy
          render_data  status: :ok
        else
          render_error errors: Rails.configuration.custom_error_msgs[:record_invalid]
        end
      end

      # DELETE /api/v1/users/:id/purge_avatar.json
      # Removes the avatar attached to the user
      def purge_avatar
        user = User.find(params[:id])
        user.avatar.purge

        render_data status: :ok
      end

      # POST /api/v1/users/change_password.json
      # Validates and change the user's password
      def change_password
        return render_error status: :forbidden if current_user.external_id?

        old_password = change_password_params[:old_password]
        new_password = change_password_params[:new_password]

        return render_error status: :bad_request if new_password.blank? || old_password.blank?

        return render_error status: :bad_request, errors: Rails.configuration.custom_error_msgs[:incorrect_old_password] unless current_user.authenticate old_password

        current_user.update! password: new_password
        render_data status: :ok
      end

      private

      def user_params
        @user_params ||= params.require(:user).permit(:name, :email, :password, :avatar, :language, :role_id, :invite_token)
      end

      def create_default_room(user)
        return unless user.rooms.count <= 0
        return unless PermissionsChecker.new(permission_names: 'CreateRoom', user_id: user.id, current_user: user, current_provider:).call

        Room.create(name: "#{user.name}'s Room", user_id: user.id)
      end

      def change_password_params
        params.require(:user).permit(:old_password, :new_password)
      end

      def valid_invite_token
        return false if user_params[:invite_token].blank?

        # Try to delete the invitation and return true if it succeeds
        Invitation.destroy_by(email: user_params[:email], provider: current_provider, token: user_params[:invite_token]).present?
      end
    end
  end
end
