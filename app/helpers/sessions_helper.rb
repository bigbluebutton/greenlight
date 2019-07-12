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
    migrate_twitter_user(user)

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

  def parse_user_domain(hostname)
    return hostname.split('.').first if Rails.configuration.url_host.empty?
    Rails.configuration.url_host.split(',').each do |url_host|
      return hostname.chomp(url_host).chomp('.') if hostname.include?(url_host)
    end
    ''
  end

  def omniauth_options(env)
    if env['omniauth.strategy'].options[:name] == "bn_launcher"
      protocol = Rails.env.production? ? "https" : env["rack.url_scheme"]

      customer_redirect_url = protocol + "://" + env["SERVER_NAME"] + ":" +
                              env["SERVER_PORT"]
      user_domain = parse_user_domain(env["SERVER_NAME"])
      env['omniauth.strategy'].options[:customer] = user_domain
      env['omniauth.strategy'].options[:customer_redirect_url] = customer_redirect_url
      env['omniauth.strategy'].options[:default_callback_url] = Rails.configuration.gl_callback_url

      # This is only used in the old launcher and should eventually be removed
      env['omniauth.strategy'].options[:checksum] = generate_checksum(user_domain, customer_redirect_url,
        Rails.configuration.launcher_secret)
    elsif env['omniauth.strategy'].options[:name] == "google"
      set_hd(env, ENV['GOOGLE_OAUTH2_HD'])
    elsif env['omniauth.strategy'].options[:name] == "office365"
      set_hd(env, ENV['OFFICE365_HD'])
    end
  end

  def set_hd(env, hd)
    if hd
      hd_opts = hd.split(',')
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

  def migrate_twitter_user(user)
    if !session["old_twitter_user_id"].nil? && user.provider != "twitter"
      old_user = User.find(session["old_twitter_user_id"])

      old_user.rooms.each do |room|
        room.owner = user

        room.name = "Old " + room.name if room.id == old_user.main_room.id

        room.save!
      end

      # Query for the old user again so the migrated rooms don't get deleted
      old_user.reload
      old_user.destroy!

      session["old_twitter_user_id"] = nil

      flash[:success] = I18n.t("registration.deprecated.merge_success")
    end
  end
end
