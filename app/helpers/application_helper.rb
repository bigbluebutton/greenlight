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

module ApplicationHelper
  def client_translations
    locale = I18n.locale
    if locale.length < 4
      fallback_locale = I18n.fallbacks[locale].second
    end

    if fallback_locale
      I18n.locale = fallback_locale
      translations = I18n.t('.')
      I18n.locale = locale
    else
      translations = I18n.t('.')
    end
    translations[:client]
  end

  def omniauth_providers_configured(provider = nil)
    if provider
      Rails.configuration.send("omniauth_#{provider}")
    else
      providers = []
      Rails.configuration.providers.each do |provider|
        providers.push(provider) if Rails.configuration.send("omniauth_#{provider}")
      end
      providers
    end
  end

  def omniauth_login_url(provider)
    "#{relative_root}/auth/#{provider}"
  end

  def log_div(seed, n)
    div = seed
    for i in 1..n
      div += seed
    end
    logger.info div
  end

  def log_hash(h)
    log_div("*", 100)
    h.sort.map do |key, value|
      logger.info "#{key}: " + "#{value}"
    end
    log_div("*", 100)
  end

  def is_active_controller(controller_name)
    params[:controller] == controller_name ? "active" : nil
  end

  def custom_authentication
    unless from_lti?
      if !current_user
        authenticate_user!
      end
    end
  end

  def from_lti?
    controller_path != 'lti' &&
    ((request.referrer && !request.referrer.include?('admin/lti') && request.referrer.include?('lti')) || request.original_fullpath.include?('lti')) &&
    !(request.original_fullpath.include?("#{relative_root}/403"))

  end

  def only_lti?
    return true if Rails.configuration.only_lti
    return false
  end

  CAP_TO_DESCRIPTIONS = {
    'accountNavigation' => 'Account Navigation',
    'courseNavigation' => 'Course Navigation',
    'assignmentSelection' => 'Assignment Selection',
    'linkSelection' => 'Link Selection'
  }

  def display_cap(cap)
    if CAP_TO_DESCRIPTIONS.keys.include? cap
      CAP_TO_DESCRIPTIONS[cap]
    else
      cap
    end
  end
end
