# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with Greenlight; if not, see <http://www.gnu.org/licenses/>.

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
        return render_error status: :forbidden if external_auth?

        # Check if this is an admin creating a user
        admin_create = current_user && PermissionsChecker.new(current_user:, permission_names: 'ManageUsers', current_provider:).call

        # Allow only administrative access for authenticated requests
        return render_error status: :forbidden if current_user && !admin_create

        registration_method = SettingGetter.new(setting_name: 'RegistrationMethod', provider: current_provider).call

        if registration_method == SiteSetting::REGISTRATION_METHODS[:invite] && !valid_invite_token && !admin_create
          return render_error errors: Rails.configuration.custom_error_msgs[:invite_token_invalid]
        end

        # TODO: Add proper error logging for non-verified token hcaptcha
        if !admin_create && hcaptcha_enabled? && !verify_hcaptcha(response: params[:token])
          return render_error errors: Rails.configuration.custom_error_msgs[:hcaptcha_invalid]
        end

        # Users created by a user will have the creator language by default with a fallback to the server configured default_locale.
        create_user_params[:language] = current_user&.language || I18n.default_locale if create_user_params[:language].blank?

        # renders an error if the user is signing up with an invalid domain based off site settings
        return render_error errors: Rails.configuration.custom_error_msgs[:banned_user], status: :forbidden unless valid_domain?

        user = UserCreator.new(user_params: create_user_params.except(:invite_token), provider: current_provider, role: default_role).call

        smtp_enabled = ENV['SMTP_SERVER'].present?

        user.verify! unless smtp_enabled

        # Set to pending if registration method is approval
        user.pending! if !admin_create && registration_method == SiteSetting::REGISTRATION_METHODS[:approval]

        if user.save
          if smtp_enabled
            token = user.generate_activation_token!
            UserMailer.with(user:,
                            activation_url: activate_account_url(token), base_url: request.base_url,
                            provider: current_provider).activate_account_email.deliver_later

            UserMailer.with(user:, admin_panel_url:, base_url: request.base_url, provider: current_provider).new_user_signup_email.deliver_later
          end

          create_default_room(user)

          return render_data data: user, serializer: CurrentUserSerializer, status: :created unless user.verified?

          user.generate_session_token!
          session[:session_token] = user.session_token unless admin_create # if this is NOT an admin creating a user

          render_data data: user, serializer: CurrentUserSerializer, status: :created
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

        # User can't change their own role
        if params[:user][:role_id].present? && current_user == user && params[:user][:role_id] != user.role_id
          return render_error errors: Rails.configuration.custom_error_msgs[:unauthorized], status: :forbidden
        end

        original_avatar = params['user']['original_avatar']
        if ENV.fetch('CLAMAV_SCANNING', 'false') == 'true' && original_avatar.present? && !Clamby.safe?(original_avatar.tempfile.path)
          user.errors.add(:avatar, 'MalwareDetected')
          return render_error errors: user.errors.to_a
        end

        if user.update(update_user_params)
          create_default_room(user)
          render_data  status: :ok
        else
          render_error errors: user.errors.to_a
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

        unless current_user.authenticate old_password
          return render_error status: :bad_request,
                              errors: Rails.configuration.custom_error_msgs[:incorrect_old_password]
        end

        current_user.update! password: new_password
        render_data status: :ok
      end

      private

      def create_user_params
        @create_user_params ||= params.require(:user).permit(:name, :email, :password, :avatar, :language, :role_id, :invite_token)
      end

      def update_user_params
        @update_user_params ||= params.require(:user).permit(permitted_params)
      end

      def change_password_params
        params.require(:user).permit(:old_password, :new_password)
      end

      def valid_invite_token
        return false if create_user_params[:invite_token].blank?

        # Try to delete the invitation and return true if it succeeds
        Invitation.destroy_by(email: create_user_params[:email].downcase, provider: current_provider,
                              token: create_user_params[:invite_token]).present?
      end

      def valid_domain?
        allowed_domains_emails = SettingGetter.new(setting_name: 'AllowedDomains', provider: current_provider).call
        return true if allowed_domains_emails.blank?

        domains = allowed_domains_emails.split(',')
        domains.each do |domain|
          return true if create_user_params[:email].end_with?(domain)
        end
        false
      end

      def permitted_params
        is_admin = PermissionsChecker.new(current_user:, permission_names: 'ManageUsers', current_provider:).call

        return %i[password avatar language role_id invite_token] if external_auth? && !is_admin

        %i[name password avatar language role_id invite_token]
      end
    end
  end
end
