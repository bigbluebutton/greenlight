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

module SessionsHelper
  # Logs a user into GreenLight.
  def login(user)
    session[:user_id] = user.id

    # If there are not terms, or the user has accepted them, check for email verification
    if !Rails.configuration.terms || user.accepted_terms
      check_email_verified(user)
    else
      redirect_to terms_path
    end
  end

  # If email verification is disabled, or the user has verified, go to their room
  def check_email_verified(user)
    # Admin users should be redirected to the admin page
    if user.has_role? :super_admin
      redirect_to admins_path
    elsif user.activated?
      # Dont redirect to any of these urls
      dont_redirect_to = [root_url, signin_url, signup_url, unauthorized_url, internal_error_url, not_found_url]
      url = if cookies[:return_to] && !dont_redirect_to.include?(cookies[:return_to])
        cookies[:return_to]
      else
        user.main_room
      end

      # Delete the cookie if it exists
      cookies.delete :return_to if cookies[:return_to]

      redirect_to url
    else
      redirect_to resend_path
    end
  end

  # Logs current user out of GreenLight.
  def logout
    session.delete(:user_id) if current_user
  end

  # Retrieves the current user.
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def generate_checksum(user_domain, redirect_url, secret)
    string = user_domain + redirect_url + secret
    OpenSSL::Digest.digest('sha1', string).unpack1("H*")
  end

  def omniauth_options(env)
    provider = env['omniauth.strategy'].options[:name]

    if Rails.configuration.loadbalanced_configuration
      user_domain = parse_user_domain(env["SERVER_NAME"])

      env['omniauth.strategy'].options[:default_callback_url] = Rails.configuration.gl_callback_url

      customer_info = retrieve_customer_info(user_domain)

      raise 'Customer not recognized' unless customer_info

      if customer_info[:saml]
        env['omniauth.strategy'].options[:issuer] = customer_info[:saml][:issuer]
        env['omniauth.strategy'].options[:idp_sso_target_url] = customer_info[:saml][:idp_sso_target_url]
        env['omniauth.strategy'].options[:idp_cert_fingerprint] = customer_info[:saml][:idp_cert_fingerprint]
      elsif customer_info[:google]
        env['omniauth.strategy'].options[:hd] = customer_info[:google][:hd] unless
          customer_info[:google][:hd].empty? || customer_info[:google][:hd] == 'gmail.com'
      elsif customer_info[:office365]
        env['omniauth.strategy'].options[:allowed_domains] = customer_info[:office365][:hd] unless
        customer_info[:office365][:hd].empty?
      end
    end

    if provider == 'google' && !Rails.configuration.loadbalanced_configuration
      hd_opts = ENV['GOOGLE_OAUTH2_HD'].split(',')
      env['omniauth.strategy'].options[:hd] =
        if hd_opts.empty?
          nil
        elsif hd_opts.length == 1
          hd_opts[0]
        else
          hd_opts
        end
    end
  end

  def retrieve_customer_info(provider)
    provider_info = retrieve_provider_info(provider, 'api2', 'getUserGreenlightCredentials')

    customer_info = {}
    if provider_info['provider'] == 'saml'
      customer_info[:saml] = {
        issuer: provider_info['SAML_ISSUER'],
        idp_sso_target_url: provider_info['SAML_IDP_URL'],
        idp_cert_fingerprint: provider_info['SAML_IDP_CERT_FINGERPRINT'],
      }
    elsif provider_info['provider'] == 'google'
      customer_info = { google: { hd: provider_info['GOOGLE_HD'] } }
    elsif provider_info['provider'] == 'office365'
      customer_info = { office365: { hd: provider_info['OFFICE_365_HD'] } }
    end

    customer_info
  end
end
