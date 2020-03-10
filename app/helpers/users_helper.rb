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

require 'i18n/language/mapping'

module UsersHelper
  include I18n::Language::Mapping

  def recaptcha_enabled?
    Rails.configuration.recaptcha_enabled
  end

  def disabled_roles(user)
    current_user_role = current_user.highest_priority_role

    # Admins are able to remove the admin role from other admins
    # For all other roles they can only add/remove roles with a higher priority
    disallowed_roles = if current_user_role.name == "admin"
                          Role.editable_roles(@user_domain).where("priority < #{current_user_role.priority}")
                              .pluck(:id)
                        else
                          Role.editable_roles(@user_domain).where("priority <= #{current_user_role.priority}")
                              .pluck(:id)
                       end

    user.roles.by_priority.pluck(:id) | disallowed_roles
  end

  # Returns language selection options for user edit
  def language_options
    locales = I18n.available_locales
    language_opts = [['<<<< ' + t("language_default") + ' >>>>', "default"]]
    locales.each do |locale|
      language_mapping = I18n::Language::Mapping.language_mapping_list[locale.to_s.gsub("_", "-")]
      language_opts.push([language_mapping["nativeName"], locale.to_s])
    end
    language_opts.sort
  end

  # Returns time zone selection options for user edit
  def timezone_options
    locales = TZInfo::Timezone.all_country_zone_identifiers
    locales.push("Etc/UTC")
    timezone_opts1 = []
    timezone_opts2 = []
    locales.each do |locale|
      timezone_mapping = ActiveSupport::TimeZone[locale].to_s
      if timezone_mapping.include? "+"
        timezone_opts1.push([timezone_mapping, locale])
      else
        timezone_opts2.push([timezone_mapping, locale])
      end
    end
    timezone_opts2 = timezone_opts2.sort { |a, b| b <=> a }
    timezone_opts2 + timezone_opts1.sort
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

  # Returns user local time
  def user_local_time(time)
    time.in_time_zone(ActiveSupport::TimeZone.new(current_user.time_zone))
  end

  # Returns a cleaner date
  def date_formatter(date)
    date.strftime('%a, %d %b %Y %H:%M')
  end
end
