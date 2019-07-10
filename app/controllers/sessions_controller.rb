# frozen_string_literal: true

# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2018 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.

class SessionsController < ApplicationController
  include Registrar
  include Emailer
  include LdapAuthenticator

  skip_before_action :verify_authenticity_token, only: [:omniauth, :fail]

  # GET /users/logout
  def destroy
    logout
    redirect_to root_path
  end

  # POST /users/login
  def create
    admin = User.find_by(email: session_params[:email])
    if admin&.has_role? :super_admin
      user = admin
    else
      user = User.find_by(email: session_params[:email], provider: @user_domain)
      redirect_to(signin_path, alert: I18n.t("invalid_user")) && return unless user
      redirect_to(root_path, alert: I18n.t("invalid_login_method")) && return unless user.greenlight_account?
      redirect_to(account_activation_path(email: user.email)) && return unless user.activated?
    end
    redirect_to(signin_path, alert: I18n.t("invalid_credentials")) && return unless user.try(:authenticate,
      session_params[:password])

    login(user)
  end

  # GET/POST /auth/:provider/callback
  def omniauth
    @auth = request.env['omniauth.auth']

    process_signin
  end

  # POST /auth/failure
  def omniauth_fail
    redirect_to root_path, alert: I18n.t(params[:message], default: I18n.t("omniauth_error"))
  end

  # GET /auth/ldap
  def ldap
    ldap_config = {}
    ldap_config[:host] = ENV['LDAP_SERVER']
    ldap_config[:port] = ENV['LDAP_PORT'].to_i != 0 ? ENV['LDAP_PORT'].to_i : 389
    ldap_config[:bind_dn] = ENV['LDAP_BIND_DN']
    ldap_config[:password] = ENV['LDAP_PASSWORD']
    ldap_config[:encryption] = if ENV['LDAP_METHOD'] == 'ssl'
                                    'simple_tls'
                                elsif ENV['LDAP_METHOD'] == 'tls'
                                    'start_tls'
                                end
    ldap_config[:base] = ENV['LDAP_BASE']
    ldap_config[:uid] = ENV['LDAP_UID']

    result = send_ldap_request(params[:session], ldap_config)

    if result
      result = result.first
    else
      return redirect_to(ldap_signin_path, alert: I18n.t("invalid_credentials"))
    end

    @auth = parse_auth(result)

    process_signin
  end

  private

  def session_params
    params.require(:session).permit(:email, :password)
  end

  def check_user_exists
    provider = @auth['provider'] == "bn_launcher" ? @auth['info']['customer'] : @auth['provider']
    User.exists?(social_uid: @auth['uid'], provider: provider)
  end

  # Check if the user already exists, if not then check for invitation
  def passes_invite_reqs
    return true if @user_exists

    invitation = check_user_invited("", session[:invite_token], @user_domain)
    invitation[:present]
  end

  def process_signin
    begin
      @user_exists = check_user_exists

      if !@user_exists && @auth['provider'] == "twitter"
        return redirect_to root_path, flash: { alert: I18n.t("registration.deprecated.twitter_signup") }
      end

      # If using invitation registration method, make sure user is invited
      return redirect_to root_path, flash: { alert: I18n.t("registration.invite.no_invite") } unless passes_invite_reqs

      user = User.from_omniauth(@auth)

      # Add pending role if approval method and is a new user
      if approval_registration && !@user_exists
        user.add_role :pending

        # Inform admins that a user signed up if emails are turned on
        send_approval_user_signup_email(user) if Rails.configuration.enable_email_verification

        return redirect_to root_path, flash: { success: I18n.t("registration.approval.signup") }
      end

      send_invite_user_signup_email(user) if Rails.configuration.enable_email_verification &&
                                             invite_registration && !@user_exists

      login(user)

      if @auth['provider'] == "twitter"
        flash[:alert] = if allow_user_signup? && allow_greenlight_accounts?
                          I18n.t("registration.deprecated.twitter_signin",
                            link: signup_path(old_twitter_user_id: user.id))
                        else
                          I18n.t("registration.deprecated.twitter_signin",
                            link: signin_path(old_twitter_user_id: user.id))
                        end
      end
    rescue => e
        logger.error "Error authenticating via omniauth: #{e}"
        omniauth_fail
    end
  end
end
