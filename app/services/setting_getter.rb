# frozen_string_literal: true

class SettingGetter
  include Rails.application.routes.url_helpers

  def initialize(setting_name:, provider:)
    @setting_name = setting_name
    @provider = provider
  end

  def call
    setting = SiteSetting.joins(:setting)
                         .find_by(
                           provider: @provider,
                           setting: { name: @setting_name }
                         )

    value = if @setting_name == 'BrandingImage' && setting.image.attached?
              rails_blob_path setting.image, only_path: true
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
