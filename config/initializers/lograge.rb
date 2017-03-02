Rails.application.configure do
  if Rails.env.production?
    config.lograge.enabled = ENV['ENABLE_CONDENSED_LOGGING'].present?
  end
end
