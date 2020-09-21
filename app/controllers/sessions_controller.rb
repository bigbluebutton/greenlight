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
  before_action :check_user_signup_allowed, only: [:new]
  before_action :ensure_unauthenticated_except_twitter, only: [:new, :signin, :ldap_signin]

  # GET /signin
  def signin
    check_if_twitter_account

    @providers = configured_providers

    if one_provider
      provider_path = if Rails.configuration.omniauth_ldap
        ldap_signin_path
      else
        "#{Rails.configuration.relative_url_root}/auth/#{@providers.first}"
      end

      redirect_to provider_path
    end
  end

  # GET /ldap_signin
  def ldap_signin
  end

  # GET /signup
  def new
    # Check if the user needs to be invited
    if invite_registration
      redirect_to root_path, flash: { alert: I18n.t("registration.invite.no_invite") } unless params[:invite_token]

      session[:invite_token] = params[:invite_token]
    end

    check_if_twitter_account(true)

    @user = User.new
  end

  # POST /users/login
  def create
    logger.info "Support: #{session_params[:email]} is attempting to login."

    user = User.include_deleted.find_by(email: session_params[:email].downcase)

    is_super_admin = user&.has_role? :super_admin

    # Scope user to domain if the user is not a super admin
    user = User.include_deleted.find_by(email: session_params[:email].downcase, provider: @user_domain) unless is_super_admin

    # Check user with that email exists
    return redirect_to(signin_path, alert: I18n.t("invalid_credentials")) unless user

    # Check if authenticators have switched
    return switch_account_to_local(user) if !is_super_admin && auth_changed_to_local?(user)

    # Check correct password was entered
    return redirect_to(signin_path, alert: I18n.t("invalid_credentials")) unless user.try(:authenticate,
      session_params[:password])
    # Check that the user is not deleted
    return redirect_to root_path, flash: { alert: I18n.t("registration.banned.fail") } if user.deleted?

    unless is_super_admin
      # Check that the user is a Greenlight account
      return redirect_to(root_path, alert: I18n.t("invalid_login_method")) unless user.greenlight_account?
      # Check that the user has verified their account
      return redirect_to(account_activation_path(digest: user.activation_digest)) unless user.activated?
    end

    login(user)
  end

  # POST /users/logout
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
    ldap_config[:auth_method] = ENV['LDAP_AUTH']
    ldap_config[:encryption] = if ENV['LDAP_METHOD'] == 'ssl'
                                    'simple_tls'
                                elsif ENV['LDAP_METHOD'] == 'tls'
                                    'start_tls'
                                end
    ldap_config[:base] = ENV['LDAP_BASE']
    ldap_config[:filter] = ENV['LDAP_FILTER']
    ldap_config[:uid] = ENV['LDAP_UID']

    if params[:session][:username].blank? || session_params[:password].blank?
      return redirect_to(ldap_signin_path, alert: I18n.t("invalid_credentials"))
    end

    result = send_ldap_request(params[:session], ldap_config)

    return redirect_to(ldap_signin_path, alert: I18n.t("invalid_credentials")) unless result

    @auth = parse_auth(result.first, ENV['LDAP_ROLE_FIELD'], ENV['LDAP_ATTRIBUTE_MAPPING'])

    begin
      process_signin
    rescue => e
      logger.error "Support: Error authenticating via omniauth: #{e}"
      omniauth_fail
    end
  end

  private

  # Verify that GreenLight is configured to allow user signup.
  def check_user_signup_allowed
    redirect_to root_path unless Rails.configuration.allow_user_signup
  end

  def session_params
    params.require(:session).permit(:email, :password)
  end

  def one_provider
    (!allow_user_signup? || !allow_greenlight_accounts?) && @providers.count == 1 &&
      !Rails.configuration.loadbalanced_configuration
  end

  def check_user_exists
    User.exists?(social_uid: @auth['uid'], provider: current_provider)
  end

  def check_user_deleted(email)
    User.deleted.exists?(email: email, provider: @user_domain)
  end

  def check_auth_deleted
    User.deleted.exists?(social_uid: @auth['uid'], provider: current_provider)
  end

  def current_provider
    @auth['provider'] == "bn_launcher" ? @auth['info']['customer'] : @auth['provider']
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

    # Check if user is deleted
    return redirect_to root_path, flash: { alert: I18n.t("registration.banned.fail") } if check_auth_deleted

    # If using invitation registration method, make sure user is invited
    return redirect_to root_path, flash: { alert: I18n.t("registration.invite.no_invite") } unless passes_invite_reqs

    # Switch the user to a social account if they exist under the same email with no social uid
    switch_account_to_social if !@user_exists && auth_changed_to_social?(@auth['info']['email'])

    user = User.from_omniauth(@auth)

    logger.info "Support: Auth user #{user.email} is attempting to login."

    # Add pending role if approval method and is a new user
    if approval_registration && !@user_exists
      user.set_role :pending

      # Inform admins that a user signed up if emails are turned on
      send_approval_user_signup_email(user)

      return redirect_to root_path, flash: { success: I18n.t("registration.approval.signup") }
    end

    send_invite_user_signup_email(user) if invite_registration && !@user_exists

    user.set_role :user if !@user_exists && user.role.nil?

    login(user)

    if @auth['provider'] == "twitter"
      flash[:alert] = if allow_user_signup? && allow_greenlight_accounts?
        I18n.t("registration.deprecated.twitter_signin", link: signup_path(old_twitter_user_id: user.id))
      else
        I18n.t("registration.deprecated.twitter_signin", link: signin_path(old_twitter_user_id: user.id))
      end
    end
  end

  # Send the user a password reset email to allow them to set their password
  def switch_account_to_local(user)
    logger.info "Switching social account to local account for #{user.uid}"

    # Send the user a reset password email
    send_password_reset_email(user, user.create_reset_digest)

    # Overwrite the flash with a more descriptive message if successful
    flash[:success] = I18n.t("reset_password.auth_change") if flash[:success].present?

    redirect_to signin_path
  end

  # Set the user's social id to the new id being passed
  def switch_account_to_social
    user = User.find_by(email: @auth['info']['email'], provider: @user_domain, social_uid: nil)

    logger.info "Switching account to social account for #{user.uid}"

    # Set the user's social id to the one being returned from auth
    user.update_attribute(:social_uid, @auth['uid'])
  end
end
