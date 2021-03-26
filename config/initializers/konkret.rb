# frozen_string_literal: true

Rails.application.configure do

  config.instance_url = ENV['INSTANCE_URL']
  config.instance_name = ENV['INSTANCE_NAME']

  config.bbb_server_origin_default = "blue.konkret-mafo.cloud"

  config.bbb_server_origin = if ENV["BBB_SERVER_ORIGIN"].present?
    ENV["BBB_SERVER_ORIGIN"]
  else
    config.bbb_server_origin_default
  end

  config.active_storage.routes_prefix = ENV["ACTIVE_STORAGE_ROUTES_PREFIX"] if ENV["ACTIVE_STORAGE_ROUTES_PREFIX"].present?

  # Default branding image if the user does not specify one
  config.branding_image_default = if ENV['LOGO_URL'].present?
    ENV['LOGO_URL']
  else
    config.instance_url + "logo_with_text.png"
  end

  # Default email branding image if the user does not specify one
  config.branding_image_email = if ENV['LOGO_EMAIL_URL'].present?
    ENV['LOGO_EMAIL_URL']
  else
    config.instance_url + "logo_email.png"
  end

  # Default branding image if the user does not specify one
  config.background_image = if ENV['BACKGROUND_IMAGE_URL'].present?
    ENV['BACKGROUND_IMAGE_URL']
  else
    config.instance_url + "bg-landing-earth.gif"
  end

  # Default branding image if the user does not specify one
  config.default_presentation_url = if ENV['DEFAULT_PRESENTATION_URL'].present?
    ENV['DEFAULT_PRESENTATION_URL']
  else
    config.instance_url + "instance_default.pdf"
  end

  config.html5_client_custom_css_url = if ENV['HTML5_CLIENT_CUSTOM_CSS_URL'].present?
     ENV['HTML5_CLIENT_CUSTOM_CSS_URL']
   else
     'https://konkret-mafo.cloud/konkret/bbb-html5.css'
   end

  config.html5_client_branding_logo_url = if ENV['HTML5_CLIENT_BRANDING_LOGO_URL'].present?
    ENV['HTML5_CLIENT_BRANDING_LOGO_URL']
  else
    'https://konkret-mafo.cloud/konkret/logo_with_text2.png'
  end

  config.neelz_email = if ENV['NEELZ_EMAIL'].present?
    ENV['NEELZ_EMAIL']
  else
    config.smtp_sender
  end

  config.neelz_email_password = if ENV['NEELZ_EMAIL_PASSWORD'].present?
    ENV['NEELZ_EMAIL_PASSWORD']
  else
    ''
  end

  config.neelz_i_share_base_url = if ENV['NEELZ_I_SHARE_BASE_URL'].present?
    ENV['NEELZ_I_SHARE_BASE_URL']
  else
    ''
  end

  config.mcu_prefix = if ENV['MCU_PREFIX'].present?
    ENV['MCU_PREFIX']
  else
    'MCU_'
  end

  config.mcu_prefix_mod = if ENV['MCU_PREFIX_MOD'].present?
    ENV['MCU_PREFIX_MOD']
  else
    'MOD_'
  end

  config.warn_participants_not_to_provide_fullname = if ENV['FULLNAME_WARN'].present?
    ENV['FULLNAME_WARN'] == "true"
  else
    false
  end

end