# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2016 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.

require 'bigbluebutton_api'
require 'digest/sha1'

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_locale

  def set_locale
    I18n.locale = http_accept_language.language_region_compatible_from(I18n.available_locales)
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
  helper_method :current_user

  def relative_root
    Rails.configuration.relative_url_root || ""
  end
  helper_method :relative_root
end
