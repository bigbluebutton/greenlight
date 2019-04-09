# frozen_string_literal: true

# List of supported Omniauth providers.
Rails.application.config.providers = []

# Set which providers are configured.
Rails.application.config.omniauth_bn_launcher = Rails.configuration.loadbalanced_configuration
Rails.application.config.omniauth_ldap = ENV['LDAP_SERVER'].present? && ENV['LDAP_UID'].present? &&
                                         ENV['LDAP_BASE'].present? && ENV['LDAP_BIND_DN'].present? &&
                                         ENV['LDAP_PASSWORD'].present?
Rails.application.config.omniauth_twitter = ENV['TWITTER_ID'].present? && ENV['TWITTER_SECRET'].present?
Rails.application.config.omniauth_google = ENV['GOOGLE_OAUTH2_ID'].present? && ENV['GOOGLE_OAUTH2_SECRET'].present?
Rails.application.config.omniauth_microsoft_office365 = ENV['OFFICE365_KEY'].present? &&
                                                        ENV['OFFICE365_SECRET'].present?

# If LDAP is enabled, override and disable allow_user_signup.
Rails.application.config.allow_user_signup = false if Rails.application.config.omniauth_ldap

SETUP_PROC = lambda do |env|
  provider = env['omniauth.strategy'].options[:name]
  if provider == "google"
    SessionsController.helpers.google_omniauth_hd env, ENV['GOOGLE_OAUTH2_HD']
  else
    SessionsController.helpers.omniauth_options env
  end
end

# Setup the Omniauth middleware.
Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.configuration.omniauth_bn_launcher
    provider :bn_launcher, client_id: ENV['CLIENT_ID'],
      client_secret: ENV['CLIENT_SECRET'],
      client_options: { site: ENV['BN_LAUNCHER_REDIRECT_URI'] },
      setup: SETUP_PROC
  elsif Rails.configuration.omniauth_ldap
    Rails.application.config.providers << :ldap

    provider :ldap,
      host: ENV['LDAP_SERVER'],
      port: ENV['LDAP_PORT'] || '389',
      method: ENV['LDAP_METHOD'].blank? ? :plain : ENV['LDAP_METHOD'].to_sym,
      allow_username_or_email_login: true,
      uid: ENV['LDAP_UID'],
      base: ENV['LDAP_BASE'],
      bind_dn: ENV['LDAP_BIND_DN'],
      password: ENV['LDAP_PASSWORD']
  else
    if Rails.configuration.omniauth_twitter
      Rails.application.config.providers << :twitter

      provider :twitter, ENV['TWITTER_ID'], ENV['TWITTER_SECRET']
    end
    if Rails.configuration.omniauth_google
      Rails.application.config.providers << :google

      provider :google_oauth2, ENV['GOOGLE_OAUTH2_ID'], ENV['GOOGLE_OAUTH2_SECRET'],
        scope: %w(profile email),
        access_type: 'online',
        name: 'google',
        setup: SETUP_PROC
    end
    if Rails.configuration.omniauth_microsoft_office365
      Rails.application.config.providers << :microsoft_office365

      provider :microsoft_office365, ENV['OFFICE365_KEY'], ENV['OFFICE365_SECRET']
    end
  end
end

# Redirect back to login in development mode.
OmniAuth.config.on_failure = proc { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}

# Work around because callback_url option causes
# omniauth.auth to be nil in the authhash when
# authenticating with LDAP.
module OmniAuthLDAPExt
  def request_phase
    rel_root = ENV['RELATIVE_URL_ROOT'].present? ? ENV['RELATIVE_URL_ROOT'] : '/b'

    @callback_path = nil
    path = options[:callback_path]
    options[:callback_path] = "#{rel_root if Rails.env == 'production'}/auth/ldap/callback"
    form = generate_form
    options[:callback_path] = path

    form
  end

  # Customize LDAP form generation
  def generate_form
    f = OmniAuth::Form.new(title: I18n.t('ldap_login'), url: callback_path)
    f.login_field 'username'
    f.password_field 'password'
    f.button "Login"
    f.to_response
  end
end

# Workaround to have access to OmniAuth::Form to customize the LDAP Form creation
module OmniAuthFormExt
  # Overrides the header to add the div.center tag
  def header(title, header_info)
    @html << <<-HTML
      <!DOCTYPE html>
      <html>
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
        <title>#{title}</title>
        #{css}
        #{header_info}
      </head>
      <body>
      <div class="center">
        <h1>#{title}</h1>
        <form method='post' #{"action='#{options[:url]}' " if options[:url]}noValidate='noValidate'>
    HTML

    self
  end

  # Creates a login_field method with our custom HTML and CSS
  def login_field(name)
    @html << <<-HTML
    <div class="form-group">
      <div class="input-icon">
        <span class="input-icon-addon">
          <i class="fas fa-at"></i>
        </span>
        <input class="form-control" placeholder="E-mail" value="" type="text" name="#{name}" id="#{name}">
      </div>
    </div>
    HTML

    self
  end

  # Creates a password_field method with our custom HTML and CSS
  def password_field(name)
    @html << <<-HTML
    <div class="form-group">
      <div class="input-icon">
        <span class="input-icon-addon">
          <i class="fas fa-key"></i>
        </span>
        <input value="" class="form-control" placeholder="Senha" type="password" name="#{name}" id="#{name}">
      </div>
    </div>
    HTML

    self
  end

  # Overrides button method with our custom HTML and CSS
  def button(text)
    @with_custom_button = true
    @html << "<input type='submit' name='commit' value='#{text}' \
              class='btn btn-outline-primary btn-block btn-pill' data-disable-with='Login'>"
  end

  protected

  # Adds the fontawesome link to the css header as well as the .scss files
  def css
    "\n<link rel='stylesheet' href='#{ActionController::Base.helpers.stylesheet_path('application.css')}'> \
     \n<link rel='stylesheet' href='#{ActionController::Base.helpers.stylesheet_path('ldap.css')}'> \
     \n<link rel='stylesheet' href='https://use.fontawesome.com/releases/v5.0.13/css/all.css' \
              integrity='sha384-DNOHZ68U8hZfKXOrtjWvjxusGo9WQnrNx2sqG0tfsghAvtVlRW3tvkXWZh58N9jp' \
              crossorigin='anonymous'>"
  end
end

# Prepends for the OmniAuth workarounds above
module OmniAuth
  module Strategies
    class LDAP
      prepend OmniAuthLDAPExt
    end
  end
end

module OmniAuth
  class Form
    prepend OmniAuthFormExt
  end
end
