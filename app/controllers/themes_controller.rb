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
  # GET /primary
  def index
    color = params[:color] || Rails.configuration.primary_color_default
    file_name = Rails.root.join('app', 'assets', 'stylesheets', 'utilities', '_primary_themes.scss')
    @file_contents = File.read(file_name)

    # Include the variables and covert scss file to css
    @compiled = Sass::Engine.new("$primary-color:#{color};" \
                                 "$primary-color-lighten:#{lighten(color)};" \
                                 "$primary-color-darken:#{darken(color)};" +
                                 @file_contents, syntax: :scss).render

    respond_to do |format|
      format.css { render body: @compiled }
    end
  end

  private

  def darken(hex_color, amount = 0.8)
    hex_color = hex_color.delete('#')
    rgb = hex_color.scan(/../).map(&:hex)
    rgb[0] = (rgb[0].to_i * amount).round
    rgb[1] = (rgb[1].to_i * amount).round
    rgb[2] = (rgb[2].to_i * amount).round
    format("#%02x%02x%02x", rgb[0], rgb[1], rgb[2])
  end

  def lighten(hex_color, amount = 0.9)
    hex_color = hex_color.delete('#')
    rgb = hex_color.scan(/../).map(&:hex)
    rgb[0] = [(rgb[0].to_i + 255 * amount).round, 255].min
    rgb[1] = [(rgb[1].to_i + 255 * amount).round, 255].min
    rgb[2] = [(rgb[2].to_i + 255 * amount).round, 255].min
    format("#%02x%02x%02x", rgb[0], rgb[1], rgb[2])
  end
end
