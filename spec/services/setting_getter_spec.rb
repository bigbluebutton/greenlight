# frozen_string_literal: true

require 'rails_helper'

describe SettingGetter, type: :service do
  before do
    Faker::Vehicle.unique.clear # Required for avoiding Faker::UniqueGenerator::RetryLimitExceeded.
  end

  describe '#call' do
    it 'returns true if the setting value is "true"' do
      site_setting = create(:site_setting, value: 'true')

      expect(described_class.new(setting_name: site_setting.setting.name, provider: site_setting.provider).call).to be true
    end

    it 'returns a string if the value isnt true or false' do
      site_setting = create(:site_setting, value: 'test_value')

      expect(described_class.new(setting_name: site_setting.setting.name, provider: site_setting.provider).call).to eq('test_value')
    end
  end
end
