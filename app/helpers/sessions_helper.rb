# frozen_string_literal: true

module SessionsHelper
  # Logs a user into GreenLight.
  def login(user)
    session[:user_id] = user.id

    # If there are not terms, or the user has accepted them, go to their room.
    if !Rails.configuration.terms || user.accepted_terms
      redirect_to user.main_room
    else
      redirect_to terms_path
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

  def generate_checksum(customer_name, redirect_url, secret)
    string = customer_name + redirect_url + secret
    OpenSSL::Digest.digest('sha1', string).unpack("H*").first
  end

  def parse_customer_name(hostname)
    provider = hostname.split('.')
    provider.first == 'www' ? provider.second : provider.first
  end

  def omniauth_options(env)
    gl_redirect_url = env["rack.url_scheme"] + "://" + env["SERVER_NAME"] + ":" + env["SERVER_PORT"]
    env['omniauth.strategy'].options[:customer] = parse_customer_name env["SERVER_NAME"]
    env['omniauth.strategy'].options[:gl_redirect_url] = gl_redirect_url
    env['omniauth.strategy'].options[:default_callback_url] = Rails.configuration.gl_callback_url
    env['omniauth.strategy'].options[:checksum] = generate_checksum parse_customer_name(env["SERVER_NAME"]),
      gl_redirect_url, Rails.configuration.launcher_secret
  end
end
