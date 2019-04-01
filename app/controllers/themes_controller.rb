# frozen_string_literal: true

# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2018 BigBlueButton Inc. and by respective authors (see below).
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

class ThemesController < ApplicationController
  before_action :provider_settings

  # GET /primary
  def index
    color = @settings.get_value("Primary Color") || Rails.configuration.primary_color_default
    file_name = Rails.root.join('app', 'assets', 'stylesheets', 'utilities', '_primary_themes.scss')
    @file_contents = File.read(file_name)

    # Include the variables and covert scss file to css
    @compiled = Sass::Engine.new("$primary-color:#{color};" \
                                 "$primary-color-lighten:lighten(#{color}, 40%);" \
                                 "$primary-color-darken:darken(#{color}, 10%);" +
                                 @file_contents, syntax: :scss).render

    respond_to do |format|
      format.css { render body: @compiled }
    end
  end

  private

  def provider_settings
    @settings = Setting.find_or_create_by(provider: user_settings_provider)
  end
end
