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
  include Authenticator
  include Registrar
  include Emailer
  include LdapAuthenticator

  skip_before_action :verify_authenticity_token, only: [:omniauth, :fail]

  # POST /users/login
  def create
    logger.info "Support: #{session_params[:email]} is attempting to login."

    admin = User.find_by(email: session_params[:email])
    if admin&.has_role? :super_admin
      user = admin
    else
      user = User.find_by(email: session_params[:email], provider: @user_domain)
      redirect_to(signin_path, alert: I18n.t("invalid_credentials")) && return unless user
      redirect_to(root_path, alert: I18n.t("invalid_login_method")) && return unless user.greenlight_account?
      redirect_to(account_activation_path(email: user.email)) && return unless user.activated?
    end
    redirect_to(signin_path, alert: I18n.t("invalid_credentials")) && return unless user.try(:authenticate,
      session_params[:password])

    login(user)
  end

  # GET /users/logout
  def destroy
    logout
    redirect_to root_path
  end

  # GET/POST /auth/:provider/callback
  def omniauth
    @auth = request.env['omniauth.auth']

    begin
      process_signin
    rescue => e
      logger.error "Error authenticating via omniauth: #{e}"
      omniauth_fail
    end
  end

  # POST /auth/failure
  def omniauth_fail
    if params[:message].nil?
      redirect_to root_path, alert: I18n.t("omniauth_error")
    else
      redirect_to root_path, alert: I18n.t("omniauth_specific_error", error: params["message"])
    end
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

    return redirect_to(ldap_signin_path, alert: I18n.t("invalid_credentials")) unless result

    @auth = parse_auth(result.first, ENV['LDAP_ROLE_FIELD'])

    begin
      process_signin
    rescue => e
      logger.error "Support: Error authenticating via omniauth: #{e}"
      omniauth_fail
    end
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
    @user_exists = check_user_exists

    if !@user_exists && @auth['provider'] == "twitter"
      return redirect_to root_path, flash: { alert: I18n.t("registration.deprecated.twitter_signup") }
    end

    # If using invitation registration method, make sure user is invited
    return redirect_to root_path, flash: { alert: I18n.t("registration.invite.no_invite") } unless passes_invite_reqs

    user = User.from_omniauth(@auth)

    logger.info "Support: Auth user #{user.email} is attempting to login."

    # Add pending role if approval method and is a new user
    if approval_registration && !@user_exists
      user.add_role :pending

      # Inform admins that a user signed up if emails are turned on
      send_approval_user_signup_email(user)

      return redirect_to root_path, flash: { success: I18n.t("registration.approval.signup") }
    end

    send_invite_user_signup_email(user) if invite_registration && !@user_exists

    login(user)

    if @auth['provider'] == "twitter"
      flash[:alert] = if allow_user_signup? && allow_greenlight_accounts?
        I18n.t("registration.deprecated.twitter_signin", link: signup_path(old_twitter_user_id: user.id))
      else
        I18n.t("registration.deprecated.twitter_signin", link: signin_path(old_twitter_user_id: user.id))
      end
    end
  end
end
