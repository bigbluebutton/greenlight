# frozen_string_literal: true

class SettingGetter
  def initialize(setting_name:, provider:)
    @setting_name = setting_name
    @provider = provider
  end

  def call
    value = SiteSetting.joins(:setting)
                       .find_by(
                         provider: @provider,
                         setting: { name: @setting_name }
                       )&.value

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
