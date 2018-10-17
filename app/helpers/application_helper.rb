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

module ApplicationHelper
  include MeetingsHelper

  # Gets all configured omniauth providers.
  def configured_providers
    Rails.configuration.providers.select do |provider|
      Rails.configuration.send("omniauth_#{provider}")
    end
  end

  # Determines which providers can show a login button in the login modal.
  def iconset_providers
    configured_providers & [:google, :twitter, :microsoft_office365]
  end

  # Generates the login URL for a specific provider.
  def omniauth_login_url(provider)
    "#{Rails.configuration.relative_url_root}/auth/#{provider}"
  end

  # Determine if Greenlight is configured to allow user signups.
  def allow_user_signup?
    Rails.configuration.allow_user_signup
  end

  # Determines if the BigBlueButton endpoint is the default.
  def bigbluebutton_endpoint_default?
    Rails.configuration.bigbluebutton_endpoint_default == Rails.configuration.bigbluebutton_endpoint
  end

  # Parses markdown for rendering.
  def markdown(text)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML,
      no_intra_emphasis: true,
      fenced_code_blocks: true,
      disable_indented_code_blocks: true,
      autolink: true,
      tables: true,
      underline: true,
      highlight: true)

    markdown.render(text).html_safe
  end
end
