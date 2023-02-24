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

# config/initializers/hcaptcha.rb

Hcaptcha.configure do |config|
  config.site_key = ENV.fetch('HCAPTCHA_SITE_KEY', nil)
  config.secret_key = ENV.fetch('HCAPTCHA_SECRET_KEY', nil)
  # # optional, default value = https://hcaptcha.com/siteverify
  # config.verify_url = 'VERIFY_URL'
  # # optional, default value = https://hcaptcha.com/1/api.js
  # config.api_script_url = 'API_SCRIPT_URL'
end
