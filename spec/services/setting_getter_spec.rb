# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with Greenlight; if not, see <http://www.gnu.org/licenses/>.

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
