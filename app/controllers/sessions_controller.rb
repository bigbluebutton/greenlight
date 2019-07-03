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

  LDAP_ATTRIBUTE_MAPPING = {
    'name' => [:cn],
    'first_name' => [:givenName],
    'last_name' => [:sn],
    'email' => [:mail, :email, :userPrincipalName],
    'nickname' => [:uid, :userid, :sAMAccountName],
    'image' => [:jpegPhoto]
  }

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

  def ldap
    result = send_ldap_request

    if result
      result = result.first
    else
      redirect_to(ldap_signin_path, alert: I18n.t("invalid_credentials"))
      return
    end

    parse_auth(result)
    process_external_signin
  end

  # GET/POST /auth/:provider/callback
  def omniauth
    begin
      @auth = request.env['omniauth.auth']
      process_external_signin
    rescue => e
        logger.error "Error authenticating via omniauth: #{e}"
        omniauth_fail
    end
  end

  # POST /auth/failure
  def omniauth_fail
    redirect_to root_path, alert: I18n.t(params[:message], default: I18n.t("omniauth_error"))
  end

  private

  def session_params
    params.require(:session).permit(:email, :password)
  end

  def check_user_exists
    provider = Rails.configuration.loadbalanced_configuration ? parse_user_domain(request.host) : @auth['provider']
    User.exists?(social_uid: @auth['uid'], provider: provider)
  end

  # Check if the user already exists, if not then check for invitation
  def passes_invite_reqs
    return true if @user_exists

    invitation = check_user_invited("", session[:invite_token], @user_domain)
    invitation[:present]
  end

  def process_external_signin
    @user_exists = check_user_exists

    # If using invitation registration method, make sure user is invited
    return redirect_to root_path, flash: { alert: I18n.t("registration.invite.no_invite") } unless passes_invite_reqs

    @auth['info']['customer'] = parse_user_domain(request.host) if Rails.configuration.loadbalanced_configuration
    user = User.from_external_provider(@auth)

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
  end

  def send_ldap_request
    host = ''
    port = 389
    bind_dn = ''
    password = ''
    encryption = nil
    base = ''
    uid = ''

    if Rails.configuration.loadbalanced_configuration
      customer = parse_user_domain(request.host)
      customer_info = retrieve_provider_info(customer, 'api2', 'getUserGreenlightCredentials')

      host = customer_info['LDAP_SERVER']
      port = customer_info['LDAP_PORT'].to_i != 0 ? customer_info['LDAP_PORT'].to_i : 389
      bind_dn = customer_info['LDAP_BIND_DN']
      password = customer_info['LDAP_PASSWORD']
      encryption = config.ldap_encryption = if customer_info['LDAP_METHOD'] == 'ssl'
                                              'simple_tls'
                                            elsif customer_info['LDAP_METHOD'] == 'tls'
                                              'start_tls'
                                            end
      base = customer_info['LDAP_BASE']
      uid = customer_info['LDAP_UID']
    else
      host = Rails.configuration.ldap_host
      port = Rails.configuration.ldap_port
      bind_dn = Rails.configuration.ldap_bind_dn
      password = Rails.configuration.ldap_password
      encryption = Rails.configuration.ldap_encryption
      base = Rails.configuration.ldap_base
      uid = Rails.configuration.ldap_uid
    end

    ldap = Net::LDAP.new(
      host: host,
      port: port,
      auth: {
        method: :simple,
        username: bind_dn,
        password: password
      },
      encryption: encryption
    )

    ldap.bind_as(
      base: base,
      filter: "(#{uid}=#{session_params[:password]})",
      password: session_params[:password]
    )
  end

  def parse_auth(result)
    @auth = {}
    @auth['info'] = {}
    @auth['uid'] = result.dn
    @auth['provider'] = :ldap

    LDAP_ATTRIBUTE_MAPPING.each do |key, value|
      value.each do |v|
        if result[v].first
          @auth['info'][key] = result[v].first
          break
        end
      end
    end
  end
end
