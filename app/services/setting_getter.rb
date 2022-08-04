# frozen_string_literal: true

class SettingGetter
  include Rails.application.routes.url_helpers

  def initialize(setting_name:, provider:, host: nil)
    @setting_name = setting_name
    @provider = provider

    return if host.nil? || setting_name != 'BrandingImage'

    Rails.application.routes.default_url_options[:host] = host # Only needed using image attachment
  end

  def call
    setting = SiteSetting.joins(:setting)
                         .find_by(
                           provider: @provider,
                           setting: { name: @setting_name }
                         )

    value = if setting.image.attached?
              url_for(setting.image)
            else
              setting&.value
            end

    transform_value(value)
  end

  private

  def transform_value(value)
    case value
    when 'true'
      true
    when 'false'
      false
    else
      value
    end
  end
end
