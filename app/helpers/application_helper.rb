# frozen_string_literal: true

module ApplicationHelper
  def branding_image
    asset_path = SettingGetter.new(setting_name: 'BrandingImage', provider: current_provider).call
    asset_url(asset_path)
  end
end
